//
//  FinalView.swift
//  EcosystemChallenge
//
//  Created by Princesa Trindade Rebouças Esmeraldo Nunes on 26/06/25.
//
import UIKit

class DesenhoView: UIView {
    init(model: DesenhoModel) {
        super.init(frame: .zero)
        configure(with: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with model: DesenhoModel) {
        backgroundColor = model.corFundo
        layer.cornerRadius = model.raioCanto
        layer.borderWidth = model.larguraBorda
        layer.borderColor = model.corBorda.cgColor
        
        // Configuração da sombra
        layer.shadowColor = model.sombra.cor.cgColor
        layer.shadowRadius = model.sombra.raio
        layer.shadowOpacity = model.sombra.opacidade
        layer.shadowOffset = model.sombra.deslocamento
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: model.tamanho.width),
            heightAnchor.constraint(equalToConstant: model.tamanho.height)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
}

class BotaoCustomizado: UIButton {
    init(model: BotaoModel) {
        super.init(frame: .zero)
        configure(with: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with model: BotaoModel) {
        setTitle(model.titulo, for: .normal)
        configuration = .filled()
        configuration?.baseBackgroundColor = model.corFundo
        configuration?.cornerStyle = model.estilo
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: model.tamanho.width),
            heightAnchor.constraint(equalToConstant: model.tamanho.height)
        ])
    }
}

class FundoGradiente: CAGradientLayer {
    init(model: FundoModel) {
        super.init()
        configure(with: model)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with model: FundoModel) {
        colors = model.cores.map { $0.withAlphaComponent(model.opacidade).cgColor }
    }
}

