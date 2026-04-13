# Sigil — Compressed Memory Format

Use this format for ALL memory types (feedback, project, reference, user). Prose is a last resort — only when no clear symbolic representation exists.

## Syntax
```
Legend: 🚫=never,▸=prefer,∈=inside,+=and,()=detail,→=leads-to,@=location,#=tag
DOMAIN:rule1,rule2,🚫anti-rule,verb(example)
```

- 3-letter uppercase domain codes,comma-separated rules,newline between domains
- Legend line is required — without it ▸ decodes wrong

## Operators
`🚫X`=never,`A▸B`=prefer-A,`verb(detail)`=do-with-specifics,`X→Y`=X-leads-to/causes-Y,`X@Y`=X-at-location-Y,`X#tag`=X-tagged,`action-before(x)`=sequence,`action-every(x)`=frequency,`action-when(x)`=conditional,`X∈Y`=X-inside-Y

## Memory Types in Sigil

### Feedback (behavioral rules)
```
STY:give-todo+user-implements,🚫workaround,🚫tangent
```

### Project (context,decisions,status)
```
PRJ:reimagine-qualifies-when(active+packaged+🚫searchable)
PRJ:storage-factory→injectable(🚫forRoot-DynamicModule),multi-bucket
PRJ:img-filenames→md5-content-hash
```

### Reference (pointers to external systems)
```
REF:pipeline-bugs@Linear(INGEST),latency-dashboard@grafana(grafana.internal/d/api-latency)
REF:name@repo(path/name-lambda),ecr@repo(path/anotherpath/env-prod/ecr.tf)
```

### User (role,goals,preferences)
```
USR:staff-eng@company(type-SE),goal→L8-by(2026),vault@(~/path/Obsidian/Default)
```

## Writing Rules
- Readable words only — vowel-stripping loses 20-40% accuracy
- Tool/command-specific rules need parenthetical inline examples: `wrap(env -i)`
- Add context words when ambiguous: `commit-single-m-flag` not `single-m`
- Fall back to prose only when symbolic form would be more ambiguous than plain text
- Target ~8-16 tokens per entry
