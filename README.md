# Multi-Objective Optimization: Aerodynamic Design (Group 8)

Este repositório contém o segundo trabalho prático da unidade curricular de **Métodos e Algoritmos para Otimização Multiobjetivo** (MAOM), lecionada pelo Professor Lino Costa no Mestrado em Engenharia e Ciência de Dados da Universidade do Minho (2025/2026).

## 🏆 Resultados e Avaliação
* **Nota Final:** 19 valores.
* **Problema:** Otimização não linear multiobjetivo aplicada ao design aerodinâmico (Main Plane e Flap).
* **Ferramentas:** MATLAB (algoritmos genéticos e métodos escalarizantes).

## 📋 Descrição do Problema
O objetivo do projeto foi otimizar o perfil de uma asa traseira de um monologar de fórmula 1, procurando o melhor compromisso (*trade-off*) entre três objetivos conflituosos:
1. **Minimização do Arrasto (Drag):** Para aumentar a eficiência/velocidade.
2. **Maximização da Sustentação (Downforce):** Para melhorar a aderência em curva.
3. **Minimização do Custo de Manufatura:** Baseado na complexidade da geometria.

### Variáveis de Decisão
Foram consideradas variáveis como o ângulo de ataque ($\alpha$), a posição relativa do *flap* (gap e overlap) e a sua inclinação, respeitando restrições geométricas e físicas para garantir soluções realistas.

## 🛠️ Metodologia Aplicada

### 1. Método Escalarizante ($\epsilon$-constraint)
Implementámos o método de restrição $\epsilon$ para transformar o problema multiobjetivo num problema mono-objetivo, tratando dois dos objetivos como restrições. Isto permitiu explorar pontos específicos da fronteira de Pareto com precisão.

### 2. Algoritmo Genético (gamultiobj)
Utilizámos a rotina `gamultiobj` do MATLAB para obter uma aproximação global da **Frente de Pareto**. Este algoritmo heurístico permitiu identificar uma grande diversidade de soluções num tempo computacional eficiente.

### 3. Análise de Métricas de Desempenho
Para comparar a qualidade das soluções obtidas pelos dois métodos, utilizámos métricas como:
* **Espaçamento (Spacing):** Para avaliar a uniformidade da distribuição das soluções.
* **Métrica de Abrangência (Maximum Spread):** Para medir a extensão da frente de Pareto coberta.



## 📈 Conclusões
Os resultados confirmaram o caráter altamente conflituoso entre a sustentação e o arrasto. A abordagem via `gamultiobj` revelou-se superior na exploração da diversidade da fronteira, enquanto os métodos escalarizantes foram úteis para validar a convergência em zonas específicas de interesse.

## 👥 Autores (Grupo 8)
* **Beatriz Peixoto** (pg59996)
* **Diogo Miranda** (pg60001)
* **Sandra Cerqueira** (pg60016)

---
*Projeto realizado para a Unidade Curricular de MAOM - Escola de Engenharia da Universidade do Minho.*
