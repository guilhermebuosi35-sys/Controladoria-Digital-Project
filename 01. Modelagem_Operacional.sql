-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Analise Operacional
-- MAGIC Essa analise busca explorar as deficiências e eficiências de um Dataset fictício voltado ao operacional de uma empresa, através de uma sequência de chamados de suporte. 
-- MAGIC
-- MAGIC Os dados coletados na tabela de exemplo são:
-- MAGIC
-- MAGIC | Nome da coluna          | Descrição                                                   |
-- MAGIC | ----------------------- | ----------------------------------------------------------- |
-- MAGIC | Ticket                  | Identificador único do ticket                               |
-- MAGIC | Sobrenome               | Sobrenome do solicitante                                    |
-- MAGIC | Departamento            | Departamento relacionado ao ticket                          |
-- MAGIC | Grupo                   | Grupo responsável ou segmentação interna                    |
-- MAGIC | Estado Civil            | Estado civil do solicitante                                 |
-- MAGIC | Idade                   | Idade do solicitante                                        |
-- MAGIC | Unidade                 | Localidade ou unidade organizacional                        |
-- MAGIC | Gênero                  | Gênero do solicitante                                       |
-- MAGIC | Classificação de Cargos | Cargo, função ou classificação do colaborador               |
-- MAGIC | Senioridade             | Nível hierárquico/senioridade do profissional               |
-- MAGIC | Responsável de TI       | Profissional de TI responsável pelo ticket                  |
-- MAGIC | Arquivado_Como          | Categorização do ticket                                     |
-- MAGIC | TicketTipo              | Tipo de ticket (ex: incidente, solicitação, requisição)     |
-- MAGIC | Severidade              | Grau de severidade do ticket                                |
-- MAGIC | Prioridade              | Prioridade atribuída ao ticket                              |
-- MAGIC | DiasAberto              | Quantidade de dias que o ticket ficou aberto                |
-- MAGIC | Satisfação              | Grau de satisfação registrado pelo usuário após atendimento |

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Tempo Médio de Atendimento (TMA)**
-- MAGIC
-- MAGIC Descreve a média de tempo que os clientes levam para ter seus tikets concluídos. 
-- MAGIC
-- MAGIC ***Interpretação***
-- MAGIC
-- MAGIC O tempo médio de 6,84 dias indica que o ciclo de resolução não é crítico, mas está acima do ideal para operações de Help Desk que buscam agilidade. O número sugere que não há gargalo grave, porém a ausência de padronização entre equipes pode estar elevando a média.
-- MAGIC

-- COMMAND ----------

SELECT ROUND(AVG(dias_aberto),2) AS media_dias_aberto
FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Desvio Padrão/Variância no Atendimento**
-- MAGIC
-- MAGIC Descreve o desvio padrão e Variância sobre os dias abertos por chamado (ticket)
-- MAGIC
-- MAGIC ***Interpretação:***
-- MAGIC
-- MAGIC O desvio padrão de 7,38 dias, maior do que a própria média, indica alta dispersão.
-- MAGIC Isso significa que alguns tickets estão sendo resolvidos rápido (baixo SLA), enquanto outros ficam muito acima do aceitável. Esse comportamento evidencia **ausência de padronização**, possível sobrecarga pontual ou falha no direcionamento dos casos mais complexos.
-- MAGIC

-- COMMAND ----------

WITH desvios_aberto AS (
SELECT
  ticket,
  dias_aberto,
  ROUND(AVG(dias_aberto) OVER (), 2) AS media_aberta, -- média de dias abertos
  ROUND(dias_aberto - ROUND(AVG(dias_aberto) OVER (), 2),2) AS desvio, -- desvios em relação a média
  ROUND(ROUND(dias_aberto - ROUND(AVG(dias_aberto) OVER (), 2),2) * ROUND(dias_aberto - ROUND(AVG(dias_aberto) OVER (), 2),2),2) AS desvio_quadrado -- desvios ao quadrado
FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
)
SELECT 
  ROUND(SUM(desvio_quadrado) / COUNT(*),2) AS variancia,
  ROUND(SQRT(SUM(desvio_quadrado) / COUNT(*)),2) AS desvio_padrao
FROM desvios_aberto;

SELECT EXPLODE (SEQUENCE (1, 10, 2))

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Ranking Departamentos**
-- MAGIC
-- MAGIC Tabela com os departamentos com maior quantidade de Tickets Abertos
-- MAGIC
-- MAGIC ***Interpretação:***
-- MAGIC
-- MAGIC Departamentos com maior volume (Finanças, Suporte Técnico, RH) apresentam melhor média de resolução, o que indica maior eficiência operacional em escala (um sinal positivo).
-- MAGIC Entretanto, os departamentos com poucos tickets têm tempos médios piores, o que é um indicador típico de que o problema pode não estar apenas no volume, mas na maturidade do fluxo de atendimento por área.

-- COMMAND ----------

SELECT ROW_NUMBER() OVER (ORDER BY COUNT(departamento) DESC) AS ranking, 
  departamento,
  COUNT (departamento) AS contagem,
  ROUND(AVG (dias_aberto),2) AS media_dias_aberto
FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
GROUP BY departamento
ORDER By contagem DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Desempenho por Severidade**
-- MAGIC
-- MAGIC Média de dias abertos de acordo com a sua severidade + média de satisfação do chamado
-- MAGIC
-- MAGIC ***Interpretação:***
-- MAGIC
-- MAGIC Chamados de severidade baixa têm SLA melhor, porém satisfação pior. Isso indica que o tempo não é o único determinante da experiência do usuário.
-- MAGIC
-- MAGIC Possíveis causas:
-- MAGIC - má comunicação;
-- MAGIC - baixa clareza da solução entregue;
-- MAGIC - tickets recorrentes / irritantes;
-- MAGIC - resolução rápida, mas superficial.
-- MAGIC
-- MAGIC Já severidades mais altas têm SLA pior porém satisfação maior, sugerindo que os analistas dedicam mais cuidado e comunicação nos casos críticos.
-- MAGIC Isso reforça a necessidade de revisar o modelo de priorização e o treinamento operacional.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC **Preliminar: Criação da Coluna `nivel_satisfacao`**
-- MAGIC
-- MAGIC 1. Adicionar a coluna
-- MAGIC ```sql
-- MAGIC ALTER TABLE workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
-- MAGIC ADD COLUMNS (nivel_satisfacao INT);
-- MAGIC ```
-- MAGIC
-- MAGIC 2. Atualizar valores com CASE WHEN
-- MAGIC ```sql
-- MAGIC UPDATE workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
-- MAGIC SET nivel_satisfacao = 
-- MAGIC     CASE 
-- MAGIC         WHEN satisfacao = '0 - Desconhecido' THEN 0
-- MAGIC         WHEN satisfacao = '1 - Insatisfeito' THEN 1
-- MAGIC         WHEN satisfacao = '2 - Satisfeito' THEN 2
-- MAGIC         WHEN satisfacao = '3 - Muito Satisfeito' THEN 3 
-- MAGIC     END;
-- MAGIC ```

-- COMMAND ----------

SELECT severidade, 
  ROUND (AVG(nivel_satisfacao),2) AS media_satisfacao,
  ROUND (AVG(dias_aberto),2) AS media_dias_aberto
FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
GROUP BY severidade
ORDER BY severidade ASC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Percentis de Dias Abertos — 25%, 50%, 75% e 90% (Por Severidade)**
-- MAGIC
-- MAGIC Levantamento dos percentis 25%, 50%, 75% e 90% para melhor entendimento da distribuição dos dias abertos dos tickets em questão
-- MAGIC
-- MAGIC ***Interpretação:***
-- MAGIC
-- MAGIC Para severidades mais críticas, o percentil 90 é significativamente maior do que nas severidades menores, mostrando uma cauda longa de tickets que demoram demais.
-- MAGIC Isso afeta diretamente SLA e percepção de eficiência.
-- MAGIC
-- MAGIC O percentil 50 (mediana) também sendo mais alto nas severidades críticas sugere que o problema não ocorre apenas em casos excepcionais: há lentidão estrutural em demandas urgentes.

-- COMMAND ----------

 SELECT COALESCE (severidade, 'Geral') AS severidade, 
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY dias_aberto) AS percentil_25, 
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY dias_aberto) AS mediana,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY dias_aberto) AS percentil_75,
  PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY dias_aberto) AS percentil_90
FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
GROUP BY ROLLUP (severidade)
ORDER BY severidade ASC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Dias Abertos por Severidade**
-- MAGIC
-- MAGIC Gráfico box com os dias abertos, de acordo com as principais severidades
-- MAGIC
-- MAGIC ***Interpretação:***
-- MAGIC
-- MAGIC Representação gráfica da analise anterior: Note como os boxes de `0 - Unclassified` e `1 - Menor` estão localizados em uma posição mais abaixo que os demais.

-- COMMAND ----------

SELECT 
      ticket,
      severidade,
      dias_aberto
      FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### **Chamados por Assunto**
-- MAGIC
-- MAGIC Quantidade de chamados de acordo com cada assunto
-- MAGIC
-- MAGIC ***Interpretação:***
-- MAGIC
-- MAGIC "Sistema" concentra o maior volume de tickets, o que pode indicar:
-- MAGIC - instabilidade recorrente;
-- MAGIC - dificuldade de usabilidade;
-- MAGIC - falta de automações;
-- MAGIC - necessidade de treinamentos.
-- MAGIC
-- MAGIC Já "Hardware" tem poucos tickets, o que indica ambiente físico estável, porém é necessário investigar se o número baixo não vem de subnotificação.

-- COMMAND ----------

SELECT arquivado_como,
  COUNT(*) AS contagem 
FROM workspace.google_drive.cenario_operacional_help_desk_tickets_it_help_desk
GROUP BY arquivado_como;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## Recomendações Estratégicas:
-- MAGIC
-- MAGIC Com base na alta **dispersão** no atendimento (Desvio Padrão > Média) e na **insatisfação** em serviços rápidos (Baixa Severidade), a estratégia deve focar em padronização e otimização do autoatendimento.
-- MAGIC
-- MAGIC ### 1. Pilar: Padronização e Previsibilidade Operacional
-- MAGIC
-- MAGIC Foco em reduzir a alta variabilidade (desvio padrão de 7,38 dias) e a lentidão estrutural em casos urgentes.
-- MAGIC
-- MAGIC | Ação Estratégica | Meta (KPI Tático) | Próximo Passo Imediato |
-- MAGIC | :--- | :--- | :--- |
-- MAGIC | **Implementação de Playbooks e SLAs Rigorosos** | Reduzir o Desvio Padrão Geral em **25%** em 6 meses. | Análise de **Desvio Padrão por Responsável/Grupo de TI** para isolar as maiores fontes de variação. |
-- MAGIC | **Transferência de Melhores Práticas** | Aumentar o TMA das áreas com menor volume em **15%**. | Modelar e replicar os fluxos eficientes dos departamentos de **alto volume** (ex: Finanças, Suporte Técnico). |
-- MAGIC
-- MAGIC ### 2. Pilar: Otimização da Experiência via Automação
-- MAGIC
-- MAGIC Abordar a baixa satisfação em tickets de **Baixa Severidade**, liberando a equipe para casos complexos.
-- MAGIC
-- MAGIC | Ação Estratégica | Meta (KPI Tático) | Próximo Passo Imediato |
-- MAGIC | :--- | :--- | :--- |
-- MAGIC | **Adoção de Self-Service e Chatbots** | Reduzir o volume de tickets de Baixa Severidade em **40%** em 3 meses. | Investimento na criação de uma **Base de Conhecimento (FAQ)** e canais de autoatendimento para problemas recorrentes em "Sistema". |
-- MAGIC | **Melhoria da Qualidade de Atendimento** | Aumentar a Satisfação Média (Nível 1 e 2) em **0.5 ponto**. | Treinamento da equipe para focar na **clareza da solução e comunicação proativa**, indo além da métrica de tempo. |
-- MAGIC
-- MAGIC ### 3. Pilar: Mitigação de Risco em Incidentes Críticos
-- MAGIC
-- MAGIC Eliminar a "cauda longa" de tickets de alta severidade (percentil P90), que ameaçam a continuidade do negócio.
-- MAGIC
-- MAGIC | Ação Estratégica | Meta (KPI Tático) | Próximo Passo Imediato |
-- MAGIC | :--- | :--- | :--- |
-- MAGIC | **Revisão do Fluxo de Escalamento Crítico** | Garantir que o Percentil 90 dos tickets críticos não ultrapasse o **P75** atual. | Mapeamento e otimização dos pontos de escalonamento para garantir que a **ação de emergência** seja disparada mais rapidamente. |