import SwiftUI

struct ReminderConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Состояния для хранения выбранных дней и времени
    @State private var selectedDays: Set<Int> = []
    @State private var selectedTime = Date()
    
    // Сохраняем начальные настройки для определения изменений
    @State private var initialDays: Set<Int> = []
    @State private var initialTime: Date?
    
    // Для отображения успешного сохранения
    @State private var showSavedMessage = false
    
    // Локализованные названия дней недели
    private let weekdays = [
        1: "Пн", 2: "Вт", 3: "Ср", 4: "Чт", 5: "Пт", 6: "Сб", 7: "Вс"
    ]
    
    // Проверяем, были ли внесены изменения
    private var hasChanges: Bool {
        let timeChanged = initialTime != nil && 
            !Calendar.current.isDate(selectedTime, equalTo: initialTime!, toGranularity: .minute)
        let daysChanged = selectedDays != initialDays
        
        return daysChanged || timeChanged
    }
    
    var body: some View {
        ZStack {
            ThemeColors.darkBlue.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Выбор дней недели
                VStack(alignment: .leading, spacing: 12) {
                    Text("Выберите дни для напоминаний")
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryText)
                        .padding(.horizontal)
                    
                    // Сетка для выбора дней недели
                    HStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { day in
                            DaySelectionButton(
                                day: weekdays[day] ?? "",
                                isSelected: selectedDays.contains(day),
                                action: {
                                    toggleDay(day)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(ThemeColors.cardBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Выбор времени
                VStack(alignment: .leading, spacing: 12) {
                    Text("Выберите время")
                        .font(.headline)
                        .foregroundColor(ThemeColors.primaryText)
                        .padding(.horizontal)
                    
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                }
                .padding(.vertical)
                .background(ThemeColors.cardBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Кнопка "Сохранить"
                Button(action: saveReminders) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(hasChanges ? ThemeColors.accent : ThemeColors.secondaryText)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(!hasChanges)
                
                // Сообщение о сохранении
                if showSavedMessage {
                    Text("Напоминания сохранены!")
                        .foregroundColor(ThemeColors.accent)
                        .padding()
                }
                
                // Текст с дополнительной информацией
                Text("Напоминания будут отправляться в выбранные дни недели в указанное время.")
                    .font(.caption)
                    .foregroundColor(ThemeColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Настройка напоминаний")
        .preferredColorScheme(.dark)
        .onAppear(perform: loadCurrentSettings)
    }
    
    // Переключение выбора дня
    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    // Загружаем текущие настройки при открытии
    private func loadCurrentSettings() {
        let settings = NotificationManager.shared.getReminderSettings()
        selectedDays = settings.days
        initialDays = settings.days
        
        if let time = settings.time {
            selectedTime = time
            initialTime = time
        } else {
            // Устанавливаем время по умолчанию на 20:00, если нет сохраненных настроек
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            if let defaultTime = Calendar.current.date(from: components) {
                selectedTime = defaultTime
            }
        }
    }
    
    // Сохраняем настройки напоминаний
    private func saveReminders() {
        NotificationManager.shared.saveReminderSettings(days: selectedDays, time: selectedTime)
        
        // Обновляем начальные значения
        initialDays = selectedDays
        initialTime = selectedTime
        
        // Показываем сообщение об успешном сохранении
        withAnimation {
            showSavedMessage = true
        }
        
        // Скрываем сообщение через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSavedMessage = false
            }
        }
    }
}

// Компонент для выбора дня недели
struct DaySelectionButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 36, height: 36)
                .background(isSelected ? ThemeColors.accent : ThemeColors.darkBlue)
                .foregroundColor(isSelected ? .white : ThemeColors.secondaryText)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? ThemeColors.accent : ThemeColors.secondaryText, lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview
struct ReminderConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReminderConfigurationView()
        }
    }
} 