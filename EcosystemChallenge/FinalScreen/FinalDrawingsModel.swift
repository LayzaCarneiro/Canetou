//
//  FinalDrawingsModel.swift
//  EcosystemChallenge
//
//  Created by Princesa Trindade Rebouças Esmeraldo Nunes on 26/06/25.
//

import UIKit

struct DesenhoModel {
    let tamanho: CGSize
    let corFundo: UIColor
    let corBorda: UIColor
    let larguraBorda: CGFloat
    let raioCanto: CGFloat
    let sombra: Sombra
    
    struct Sombra {
        let cor: UIColor
        let raio: CGFloat
        let opacidade: Float
        let deslocamento: CGSize
    }
    
    static let padrao = DesenhoModel(
        tamanho: CGSize(width: 515, height: 415),
        corFundo: .white,
        corBorda: .black,
        larguraBorda: 1,
        raioCanto: 10,
        sombra: Sombra(
            cor: .black,
            raio: 8,
            opacidade: 0.25,
            deslocamento: CGSize(width: 0, height: 4)
    )
        )
}

struct BotaoModel {
    let titulo: String
    let corFundo: UIColor
    let estilo: UIButton.Configuration.CornerStyle
    let tamanho: CGSize
    
    static let finalizar = BotaoModel(
        titulo: "Finalizar",
        corFundo: .systemIndigo,
        estilo: .large,
        tamanho: CGSize(width: 315, height: 55))
    
    static let tentarNovamente = BotaoModel(
        titulo: "Tentar novamente",
        corFundo: .systemIndigo,
        estilo: .large,
        tamanho: CGSize(width: 315, height: 55))
        
}

struct FundoModel {
    let cores: [UIColor]
    let opacidade: CGFloat
    
    static let padrao = FundoModel(
        cores: [.systemMint, .systemYellow, .systemOrange, .systemRed, .systemIndigo],
        opacidade: 0.2)
}
