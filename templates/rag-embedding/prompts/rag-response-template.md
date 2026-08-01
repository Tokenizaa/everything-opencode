# RAG Response Template

## Response Structure

```markdown
## Answer
[Sua resposta baseada no contexto recuperado, citando fontes]

## Sources
- [chunk_id] Title: "..." — "trecho relevante"
- [chunk_id] Title: "..." — "trecho relevante"

## Confidence
[High/Medium/Low] — [Justificativa]
```

## Guidelines

### Citation Format
- Use `[chunk_id]` or `[title]` for inline citations
- Quote relevant excerpts verbatim when possible
- Maximum 2-3 citations per claim

### Confidence Levels

| Level | Criteria |
|---|---|
| **High** | Múltiplas fontes concordam, contexto direto |
| **Medium** | Fonte única confiável, ou inferência razoável |
| **Low** | Inferência indireta, contexto parcial |

### Response Structure by Use Case

#### Generation (Content Creation)
```
## Answer
[Conteúdo gerado seguindo framework do domínio]

## Sources
- [chunk_id] Title: "..." — "trecho relevante"

## Confidence
High — Múltiplas fontes concordam, contexto direto
```

#### Compliance (Legal/Regulatory)
```
## Answer
[Resposta baseada no contexto, citando artigos/leis]

## Sources
- [chunk_id] Title: "..." — "trecho com artigo/lei"

## Confidence
Medium — Fonte única confiável, mas inferência necessária
```

#### Theme Suggestion
```
## Answer
[Sugestões baseadas em temas recuperados]

## Sources
- [chunk_id] Title: "..." — "trecho relevante"

## Confidence
Medium — Baseado em temas recuperados, requer validação
```

#### Compliance (Legal)
```
## Answer
[Resposta baseada no contexto, citando artigos/leis]

## Sources
- [chunk_id] Title: "..." — "trecho com artigo/lei"

## Confidence
Medium — Fonte única confiável, mas inferência necessária
```

## Anti-Patterns to Avoid

- ❌ Inventar citações/referências
- ❌ Generalizar além do contexto
- ❌ Ignorar contradições entre fontes
- ❌ Apresentar inferência como fato
- ❌ Omitir incerteza

## Quality Checklist

- [ ] Todas as claims têm fonte citada
- [ ] Citações são verbatim do contexto
- [ ] Incerteza explicitamente declarada
- [ ] Formato segue template do use case
- [ ] Confidence level justificado
SKILLEOF