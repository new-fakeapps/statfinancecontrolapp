import SwiftUI

struct ReminderConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDays: Set<Int> = []
    @State private var selectedTime = Date()
    
    // Начальные настройки для сравнения
    @State private var initialDays: Set<Int> = []
    @State private var initialTime = Date()
    @State private var hasChanges = false
    
    // Статус уведомлений
    @State private var isNotificationsRemoved = false
    @State private var showFeedback = false
    
    private let weekDays = [
        (1, "Пн"), (2, "Вт"), (3, "Ср"),
        (4, "Чт"), (5, "Пт"), (6, "Сб"), (7, "Вс")
    ]
    
    // Функция для определения наличия изменений
    private func checkForChanges() {
        // Проверяем, изменились ли дни или время
        let daysChanged = selectedDays != initialDays
        
        // Для сравнения времени смотрим только часы и минуты
        let calendar = Calendar.current
        let selectedHour = calendar.component(.hour, from: selectedTime)
        let selectedMinute = calendar.component(.minute, from: selectedTime)
        let initialHour = calendar.component(.hour, from: initialTime)
        let initialMinute = calendar.component(.minute, from: initialTime)
        
        let timeChanged = (selectedHour != initialHour) || (selectedMinute != initialMinute)
        
        // Обновляем флаг изменений
        hasChanges = daysChanged || timeChanged
        
        // Обновляем статус для визуальной обратной связи
        isNotificationsRemoved = selectedDays.isEmpty && hasChanges
    }
    
    // Функция для сохранения изменений
    private func saveChanges() {
        NotificationManager.shared.saveReminderSettings(
            days: selectedDays,
            time: selectedTime
        )
        
        // После сохранения обновляем начальные значения и сбрасываем флаг изменений
        initialDays = selectedDays
        initialTime = selectedTime
        hasChanges = false
        
        // Показываем обратную связь, если настройки приводят к отключению уведомлений
        if selectedDays.isEmpty {
            showFeedback = true
            
            // Автоматически скрываем сообщение через 3 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showFeedback = false
            }
        }
    }
    
    // Функция отмены изменений
    private func cancelChanges() {
        dismiss()
    }
    
    var body: some View {
        ZStack {
            // Основное содержимое
            ThemeColors.darkBlue.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Days selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Дни недели")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(weekDays, id: \.0) { day in
                            DayToggleButton(
                                day: day.1,
                                isSelected: selectedDays.contains(day.0),
                                action: {
                                    if selectedDays.contains(day.0) {
                                        selectedDays.remove(day.0)
                                    } else {
                                        selectedDays.insert(day.0)
                                    }
                                    checkForChanges()
                                }
                            )
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                // Time selection
                VStack(alignment: .leading, spacing: 15) {
                    Text("Время напоминания")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: selectedTime) { _ in
                        checkForChanges()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                // Визуальная обратная связь при отключении уведомлений
                if isNotificationsRemoved {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "bell.slash")
                                .foregroundColor(.orange)
                            Text("Внимание!")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        Text("Не выбран ни один день недели. Сохранение приведет к отключению всех напоминаний.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                }
                
                // Сообщение обратной связи после сохранения
                if showFeedback {
                    Text("Напоминания отключены – не выбран ни один день.")
                        .font(.subheadline)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showFeedback)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Напоминания")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") {
                    cancelChanges()
                }
                .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveChanges()
                    dismiss()
                }
                .foregroundColor(.white)
                .disabled(!hasChanges)
                .opacity(hasChanges ? 1.0 : 0.5)
            }
        }
        .onAppear {
            let settings = NotificationManager.shared.getReminderSettings()
            
            // Установка текущих значений
            selectedDays = settings.days
            if let time = settings.time {
                selectedTime = time
            }
            
            // Сохранение начальных значений для сравнения
            initialDays = selectedDays
            initialTime = selectedTime
            
            // Сбрасываем флаг изменений, так как это начальное состояние
            hasChanges = false
            isNotificationsRemoved = selectedDays.isEmpty
        }
    }
}

struct DayToggleButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.white : Color.gray.opacity(0.3))
                .cornerRadius(20)
        }
    }
}

#Preview {
    ReminderConfigurationView()
} 
