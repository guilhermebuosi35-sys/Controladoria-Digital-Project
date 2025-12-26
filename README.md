# Controladoria Digital - Sistema de Apoio à Decisão

![Status do Projeto](https://img.shields.io/badge/Status-Concluído-brightgreen)
![Databricks](https://img.shields.io/badge/Databricks-Spark-FF3621?logo=databricks&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-003B57?logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?logo=powerbi&logoColor=black)

Um projeto completo de Analytics simulando uma Controladoria Digital, integrando análise de dados massivos (Databricks) com visualização estratégica para tomada de decisão em três níveis organizacionais.

---

## Live Demo
Acesse o portal do projeto com os dashboards interativos e documentação técnica:
### [Acessar Controladoria Digital (GitHub Pages)](https://guilhermebuosi35-sys.github.io/Controladoria-Digital-Project/)

---

## O Desafio de Negócio
O objetivo deste projeto foi desenvolver uma solução de dados capaz de suportar a tomada de decisão em uma empresa fictícia, cobrindo as lacunas de informação entre a operação diária e a estratégia de longo prazo.

A solução foi estruturada em três pilares fundamentais:

### 1. Nível Operacional (Help Desk & Suporte)
* **Foco:** Eficiência e Qualidade.
* **Problema:** Alta variância no tempo de atendimento e gargalos em tickets críticos.
* **Solução:** Análise estatística de tickets (SLA, TME/TMA), identificação de outliers e produtividade por analista.
* **Técnicas:** Window Functions, Cálculo de Variância/Desvio Padrão, Percentis (P90, P50).

### 2. Nível Tático (Vendas & CRM)
* **Foco:** Performance Comercial e Custos.
* **Problema:** Necessidade de acompanhar o funil de conversão e eficiência de aquisição.
* **Solução:** Monitoramento de Funil de Vendas, CAC (Custo de Aquisição de Cliente) e LTV (Lifetime Value).

### 3. Nível Estratégico (Financeiro & Executivo)
* **Foco:** Rentabilidade e Sustentabilidade.
* **Problema:** Visão consolidada de receitas e margens para investidores/diretoria.
* **Solução:** DRE Gerencial, projeção de receitas, custos fixos/variáveis e margem de contribuição por linha de produto.

---

## Stack Tecnológico

Este projeto utiliza uma arquitetura híbrida de processamento e visualização:

* **Processamento (ETL & Analytics):**
    * **Databricks (PySpark/SQL):** Para ingestão, limpeza e cálculos estatísticos complexos.
    * **SQL Avançado:** Uso extensivo de CTEs (Common Table Expressions), Window Functions (`OVER`, `PARTITION BY`) e Funções Estatísticas (`PERCENTILE_CONT`, `CORR`).
* **Visualização:**
    * **Power BI:** Para prototipagem dos dashboards visuais.
* **Versionamento:**
    * **Git & GitHub Pages:** Hospedagem da documentação e do portal visual.

---

## Isenção de Responsabilidade & Contexto Acadêmico

Este projeto foi desenvolvido exclusivamente para fins educacionais e acadêmicos, como requisito para aprovação na Universidade São Judas Tadeu (USJT).

* **Natureza dos Dados:** Os dados apresentados neste repositório são fictícios ou foram anonimizados e descaracterizados para fins de simulação acadêmica. Não representam a realidade financeira ou operacional de nenhuma empresa ativa.
* **Empresas Terceiras:** A menção a quaisquer empresas terceiras ou parceiras neste projeto serve estritamente como cenário para o estudo de caso. Não há vínculo comercial ou fins lucrativos associados a este repositório.
* **Uso Permitido:** O código fonte está disponível para consulta e estudo, mas a redistribuição ou uso comercial das marcas citadas é restrita aos seus detentores legais.

---

## Estrutura do Repositório

```text
Controladoria-Digital-Project/
├── assets/             # Imagens, Logos e GIFs dos dashboards
├── notebooks/          # O Coração do projeto (Análises Técnicas)
│   ├── analise-operacional.ipynb   # Código SQL/Python da análise de suporte
│   ├── analise-tatica.ipynb        # Código SQL/Python da análise de vendas
│   ├── analise-estrategica.ipynb   # Código SQL/Python da análise financeira
│   └── html/                       # Exports dos notebooks renderizados (Databricks)
├── index.html          # Portal de navegação do projeto
└── README.md           # Documentação oficial
