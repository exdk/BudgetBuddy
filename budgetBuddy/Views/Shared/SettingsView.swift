import SwiftUI

struct SettingsView: View {
    @AppStorage("theme") private var theme: Theme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Внешний вид") {
                    Picker("Тема", selection: $theme) {
                        ForEach(Theme.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }
                
                Section("Управление") {
                    NavigationLink("Категории") {
                        CategoryListView()
                    }
                    NavigationLink("Счета") {
                        AccountListView()
                    }
                }
                
                Section("Экспорт и резервное копирование") {
                    Button("Экспорт данных (CSV)") {
                        // Будущая реализация
                    }
                    Button("Резервное копирование в iCloud") {
                        // Будущая реализация
                    }
                }
                
                Section("О приложении") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BudgetBuddy")
                            .font(.headline)
                        Text("Версия 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Учет доходов и расходов с матричным планированием.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
}
