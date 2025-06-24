# Ecosystem Challenge - PencilKit

O projeto é um app cujo objetivo é gerar uma experiência compartilhada entre dois usuários desenhando com um conjunto predefinido de canetas e cores.
Construído com **UIKit** no padrão **MVC**.

**Tecnologias utilizadas**
- UIKit para construção das interfaces
- SharePlay para conexão entre usuários
- PencilKit para desenhos
- Combine
- GroupActivities

---

## 🗂 Estrutura de Pastas

```plaintext
EcosystemChallenge/
│
├── Models/ # Dados e lógica (Ex: User)
│ └── User.swift
│
├── HomeScreen/
│ └── HomeView.swift # Toda a UI (botões, labels, collectionViews)
│ └── HomeViewController.swift # Lógica e eventos (ações dos botões, navegação)
│
├── Resources/ # Assets, LaunchScreen, Info.plist etc.
│
├── Utils/ # Código auxiliares e extensões úteis para UIKit, String, etc.
│
├── AppDelegate.swift
└── SceneDelegate.swift
