//
//  MatrixGridView.swift
//  budgetBuddy
//
//  Created by Виктор Юнусов on 15.09.2025.
//


import SwiftUI

struct MatrixGridView: View {
    let data: MatrixViewData
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 0) {
                // Заголовок с датами
                headerRow
                
                // Доходы
                Text("ДОХОДЫ")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                
                ForEach(data.incomeCategories, id: \.id) { category in
                    categoryRow(category: category, values: data.incomeValues[category.name] ?? [], isIncome: true)
                }
                
                // Итог по доходам
                totalRow(title: "ВСЕГО ДОХОДЫ", values: data.totalIncome, isIncome: true)
                
                // Расходы
                Text("РАСХОДЫ")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                
                ForEach(data.expenseCategories, id: \.id) { category in
                    categoryRow(category: category, values: data.expenseValues[category.name] ?? [], isIncome: false)
                }
                
                // Итог по расходам
                totalRow(title: "ВСЕГО РАСХОДЫ", values: data.totalExpense, isIncome: false)
                
                // Остаток
                totalRow(title: "ОСТАТОК", values: data.balance, isIncome: true)
            }
        }
    }
    
    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Категория")
                .font(.headline)
                .frame(width: 150, alignment: .leading)
                .padding(8)
                .background(Color.gray.opacity(0.2))
            
            ForEach(data.dates, id: \.self) { date in
                Text(date, format: .dateTime.day().month())
                    .font(.headline)
                    .frame(width: 80, alignment: .center)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
            }
        }
    }
    
    private func categoryRow(category: Category, values: [Double], isIncome: Bool) -> some View {
        HStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(colorFromString(category.color))
                    .frame(width: 12, height: 12)
                Text(category.name)
                    .font(.system(size: 12))
            }
            .frame(width: 150, alignment: .leading)
            .padding(8)
            
            ForEach(values.indices, id: \.self) { index in
                Text(values[index] == 0 ? "-" : formatCurrency(values[index]))
                    .font(.system(size: 12))
                    .frame(width: 80, alignment: .center)
                    .padding(8)
                    .foregroundColor(isIncome ? .green : .red)
            }
        }
        .background(Color.gray.opacity(0.1))
    }
    
    private func totalRow(title: String, values: [Double], isIncome: Bool) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.headline)
                .frame(width: 150, alignment: .leading)
                .padding(8)
                .background(isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
            
            ForEach(values.indices, id: \.self) { index in
                Text(values[index] == 0 ? "-" : formatCurrency(values[index]))
                    .font(.headline)
                    .frame(width: 80, alignment: .center)
                    .padding(8)
                    .foregroundColor(isIncome ? .green : .red)
                    .background(isIncome ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
            }
        }
    }
}