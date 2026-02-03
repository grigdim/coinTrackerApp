//
//  CategoriesMapper.swift
//  CoinTrackerApp
//
//  Created by Dim Grigoriadis on 31/1/26.
//

enum CategoryMapper {
    static func map(_ dto: CategoryDTO) -> Category {
        Category(id: dto.categoryId, name: dto.name)
    }
}
