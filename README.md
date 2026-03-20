# Task Manager App - Flutter 🚀

---

## 📱 Sobre o Projeto

Trata-se de um aplicativo interativo de gerenciamento de tarefas (To-Do List) construído em Flutter.

O objetivo principal do projeto é aplicar os conceitos fundamentais de gerenciamento de estado no Flutter, utilizando `StatefulWidget`, `setState()` e o gerenciamento de ciclo de vida (`dispose()`). O app permite uma manipulação dinâmica de dados, atualizando a interface em tempo real conforme as interações do usuário.

---

## ✨ Funcionalidades Implementadas

O projeto atende a 100% dos requisitos obrigatórios e implementa diversos recursos extras de UI/UX e gerenciamento de dados.

### 📌 Funcionalidades Obrigatórias

- **Adicionar Tarefas:** Entrada de texto via `TextField` para registrar novas atividades, com limpeza automática do campo após a inclusão.
- **Listagem de Tarefas:** Exibição dinâmica utilizando `ListView`, com tratamento de estado vazio (Empty State personalizado).
- **Marcar como Concluída:** Utilização de `Checkbox` ao lado de cada tarefa. Quando marcada, o texto recebe o estilo riscado (`TextDecoration.lineThrough`) e muda de cor.
- **Remover Tarefas:** Exclusão de itens de forma fluida da lista.

### 🌟 Elementos Opcionais

- **Contador Dinâmico:** Dashboard exibindo o progresso, total de tarefas e total de tarefas concluídas em tempo real.
- **Filtros de Visualização:** Chips para filtrar a visualização entre "Todas", "Pendentes" e "Concluídas".
- **Limpeza Rápida:** Botão dedicado na `AppBar` para apagar simultaneamente todas as tarefas já finalizadas.
- **Identidade Visual Visual:** Cores e estilos diferentes para diferenciar rapidamente tarefas pendentes de concluídas.
- **Animações:** Implementação do widget `Dismissible` para exclusão de tarefas arrastando para o lado (Swipe to delete).

### 🚀 Extras

- **Modo Kanban:** Visualização alternativa em colunas (Pendentes e Concluídas) com suporte a _Drag and Drop_ interativo.
- **Dark Mode / Light Mode:** Suporte nativo à alternância de temas claro e escuro.
- **Timestamps:** Registro automático da data e hora exata de criação e de conclusão de cada tarefa.

---

## 📸 Screenshots


<div align="center">
  <img src="/assets/empty.png" width="250" alt="Lista Vazia">
  <img src="/assets/tasks.png" width="250" alt="Com Tarefas">
  <img src="/assets/kanban1.png" width="250" alt="Tarefas no Kanban">
  <img src="/assets/kanban2.png" width="250" alt="Tarefas no Kanban">
</div>

---

## 🛠️ Requisitos Técnicos Aplicados

- Estrutura baseada em `StatefulWidget`.
- Criação de uma classe modelo `Tarefa` customizada.
- Armazenamento em memória com `List<Tarefa>`.
- Gerenciamento de input com `TextEditingController` e limpeza segura de memória com `dispose()`.
- Atualização rigorosa da interface via `setState()`.
