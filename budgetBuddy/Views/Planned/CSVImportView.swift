// ЗАМЕНИТЕ СОДЕРЖИМОЕ CSVImportView.swift на:
import SwiftUI

struct CSVImportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "table")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Импорт CSV")
                    .font(.title2)
                
                Text("В текущей версии импорт CSV временно недоступен. Матричный планировщик теперь использует ваши существующие запланированные операции.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("Закрыть") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Импорт CSV")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
