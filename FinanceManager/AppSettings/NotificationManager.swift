import Foundation
import UserNotifications

public class NotificationManager {
    public static let shared = NotificationManager()
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private let reminderSettingKey = "activeReminderSetting"
    
    private init() {}
    
    // MARK: - Permission Handling
    
    public func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            print("Current notification settings - Authorization status: \(settings.authorizationStatus.rawValue)")
            switch settings.authorizationStatus {
            case .notDetermined:
                print("Requesting notification permission...")
                self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("Error requesting notification permission: \(error)")
                    }
                    print("Notification permission granted: \(granted)")
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            case .authorized, .provisional, .ephemeral:
                print("Notifications already authorized")
                DispatchQueue.main.async {
                    completion(true)
                }
            case .denied:
                print("Notifications are denied")
                DispatchQueue.main.async {
                    completion(false)
                }
            @unknown default:
                print("Unknown notification authorization status")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Settings Management
    
    // Структура для хранения настроек напоминания
    struct ReminderSetting: Codable {
        let days: Set<Int>
        let time: Date
        
        init(days: Set<Int>, time: Date) {
            self.days = days
            self.time = time
        }
    }
    
    public func saveReminderSettings(days: Set<Int>, time: Date) {
        print("Saving reminder settings - Days: \(days), Time: \(time)")
        
        // Всегда сначала отменяем все существующие уведомления
        // для предотвращения дублирования
        cancelAllReminders()
        
        // Если нет выбранных дней, просто выходим после отмены
        if days.isEmpty {
            print("🚫 No days selected, notifications cancelled")
            return
        }
        
        // Создаем новую настройку
        let newSetting = ReminderSetting(days: days, time: time)
        
        // Сохраняем настройку
        if let data = try? JSONEncoder().encode(newSetting) {
            userDefaults.set(data, forKey: reminderSettingKey)
        }
        
        // Планируем уведомления для новой настройки
        scheduleNotifications(for: newSetting)
    }
    
    // Получить текущие настройки напоминаний
    public func getReminderSettings() -> (days: Set<Int>, time: Date?) {
        guard let data = userDefaults.data(forKey: reminderSettingKey),
              let setting = try? JSONDecoder().decode(ReminderSetting.self, from: data) else {
            return ([], nil)
        }
        return (setting.days, setting.time)
    }
    
    // MARK: - Notification Scheduling
    
    // Планирование уведомлений для конкретной настройки
    private func scheduleNotifications(for setting: ReminderSetting) {
        let calendar = Calendar.current
        
        // Извлекаем только время из выбранной даты
        let timeComponents = calendar.dateComponents([.hour, .minute], from: setting.time)
        let hour = timeComponents.hour ?? 0
        let minute = timeComponents.minute ?? 0
        
        print("⏰ Scheduling notifications for days: \(setting.days), time: \(hour):\(minute)")
        
        for weekday in setting.days {
            // Создаем только еженедельные повторяющиеся уведомления
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            // Конвертируем наш формат дня недели в системный
            // В системе: 1=воскресенье, 2=понедельник, ..., 7=суббота
            // В нашем коде: 1=понедельник, 2=вторник, ..., 7=воскресенье
            let systemWeekday = weekday == 7 ? 1 : weekday + 1
            dateComponents.weekday = systemWeekday
            
            print("📆 Setting notification for weekday: \(weekday) (system: \(systemWeekday)) at \(hour):\(minute)")
            
            // Создаем контент уведомления
            let content = UNMutableNotificationContent()
            content.title = "Напоминание о внесении средств"
            content.body = "Пора записать доход или расход. Не забудьте зафиксировать изменения в бюджете!"
            content.sound = .default
            
            // Создаем календарный триггер для повторяющихся уведомлений
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, 
                repeats: true
            )
            
            // Проверяем, когда сработает следующее уведомление
            if let nextFireDate = trigger.nextTriggerDate() {
                print("📅 Next fire date for weekday \(weekday): \(nextFireDate)")
            }
            
            // Создаем фиксированный идентификатор для каждого дня
            // Это гарантирует, что будет только одно уведомление на каждый день
            let identifier = "financeReminder-day-\(weekday)"
            
            // Создаем запрос на уведомление
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            // Добавляем запрос
            notificationCenter.add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error)")
                } else {
                    print("✅ Successfully scheduled notification for weekday \(weekday)")
                }
            }
        }
        
        // Проверяем все запланированные уведомления
        checkAllScheduledNotifications()
    }
    
    // Проверяем все запланированные уведомления
    private func checkAllScheduledNotifications() {
        notificationCenter.getPendingNotificationRequests { requests in
            print("📊 Total scheduled notifications: \(requests.count)")
            for request in requests {
                print("🔔 Notification ID: \(request.identifier)")
                
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let nextDate = trigger.nextTriggerDate() {
                    print("📆 \(request.identifier) will fire at: \(nextDate), repeats: \(trigger.repeats)")
                }
                
                if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                   let nextDate = Calendar.current.date(byAdding: .second, value: Int(trigger.timeInterval), to: Date()) {
                    print("⏱️ \(request.identifier) will fire at: \(nextDate), repeats: \(trigger.repeats)")
                }
            }
        }
    }
    
    // Создает тестовое уведомление через 15 секунд
    public func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Тестовое уведомление"
        content.body = "Это тестовое финансовое уведомление для проверки работы системы."
        content.sound = .default
        
        // Создаем уведомление через 15 секунд
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "testFinanceNotification",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Error scheduling test notification: \(error)")
            } else {
                print("✅ Test notification scheduled, will fire in 15 seconds")
            }
        }
    }
    
    // Удаляет все уведомления и настройки
    public func cancelAllReminders() {
        print("🧹 Cancelling all pending finance reminders")
        
        // Получаем все запланированные уведомления
        notificationCenter.getPendingNotificationRequests { requests in
            // Фильтруем только уведомления с нашим идентификатором
            let financeReminderIds = requests
                .filter { $0.identifier.starts(with: "financeReminder") }
                .map { $0.identifier }
            
            // Удаляем только финансовые напоминания
            if !financeReminderIds.isEmpty {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: financeReminderIds)
                print("🗑️ Removed \(financeReminderIds.count) finance reminders")
            }
        }
    }
} 

