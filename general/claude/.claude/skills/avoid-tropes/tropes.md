# AI Writing Tropes to Avoid (Sigil)

Source: [tropes.fyi](https://tropes.fyi). Compressed for token efficiency. One pattern used once may be fine; the problem is repetition or stacking. Write like a human: varied, imperfect, specific.

```
Legend: 🚫=never,▸=prefer,∈=inside,+=and,()=detail,→=leads-to,@=location,#=tag,vs=instead-of
```

## Post-write checklist (do this every time)
1. Literal-search your draft for `—` (U+2014 em-dash). If found, rewrite with comma/period/parens.
2. Literal-search for `**Word**:` or paragraphs starting with `**Bold phrase**`. If found, unbold.
3. Read every sentence with "not" — if you wrote "It's not X, it's Y" or "Not X. Not Y. Z.", rewrite.
4. Check for headers like "The Takeaway", "In Summary", "Wrap-up", "Final Thoughts". Delete them.

## Word Choice
```
WRD:🚫magic-adverbs(quietly,deeply,fundamentally,remarkably,arguably)
WRD:🚫overused-vocab(delve,certainly,utilize,leverage-verb,robust,streamline,harness)
WRD:🚫grandiose-nouns(tapestry,landscape,paradigm,synergy,ecosystem,framework-as-filler)
WRD:🚫serves-as-dodge(serves-as,stands-as,marks,represents)▸is/are
```

## Sentence Structure
```
SNT:🚫negative-parallelism(It's-not-X-it's-Y,not-because-X-but-because-Y)#most-common-AI-tell
SNT:🚫dramatic-countdown(Not-X.Not-Y.Just-Z.)
SNT:🚫self-rhetorical(The-X?A-Y.,The-result?Devastating.)
SNT:🚫anaphora(They-assume...They-assume...They-assume)
SNT:🚫tricolon-stacking(>1-rule-of-3-back-to-back)
SNT:🚫filler-transitions(It's-worth-noting,It-bears-mentioning,Importantly,Interestingly,Notably)
SNT:🚫superficial-ing-tails(highlighting-its-importance,reflecting-broader-trends,underscoring-its-role)
SNT:🚫false-ranges(from-X-to-Y-when-no-real-spectrum)
SNT:🚫gerund-fragments-after-claim(Fixing-bugs.Writing-features.Shipping-faster.)→subjectless-fragments-padding-prior-sentence
```

## Paragraph Structure
```
PAR:🚫short-punchy-fragments-as-paragraphs(He-published-this.Openly.In-a-book.)
PAR:🚫listicle-in-trench-coat(The-first...The-second...The-third...wrapped-as-prose)
```

## Tone
```
TON:🚫false-suspense(Here's-the-kicker,Here's-the-thing,Here's-where-it-gets-interesting)
TON:🚫false-exclusivity(the-part-nobody-talks-about,what-most-people-miss)▸only-if-genuinely-obscure
TON:🚫patronizing-analogy(Think-of-it-as,It's-like-a-Swiss-Army-knife)
TON:🚫cliched-idioms(smoking-gun,perfect-storm,move-the-needle,end-of-the-day,game-changer,double-edged-sword,tip-of-the-iceberg)
TON:🚫futurism-invite(Imagine-a-world-where...)
TON:🚫false-vulnerability(And-yes-I'm-openly...,since-we're-being-honest)→performative
TON:🚫assert-simple(The-truth-is-simple,History-is-clear)▸prove-it
TON:🚫stakes-inflation(will-define-the-next-era,fundamentally-reshape-everything)
TON:🚫pedagogical-voice(Let's-break-this-down,Let's-unpack,Let's-dive-in,Let's-explore)
TON:🚫vague-attributions(experts-argue,industry-reports-suggest,observers-cited)▸name-source
TON:🚫invented-concept-labels(coining-fake-jargon-by-appending-paradox/trap/creep/divide/vacuum/inversion-to-domain-word,eg-supervision-paradox,acceleration-trap)
```

## Formatting
```
FMT:🚫em-dash-char(—,U+2014,never-emit-this-glyph)▸parentheses-or-comma-or-period(if-you-typed-em-dash-rewrite)
FMT:🚫bold-first-anything(bullets-OR-paragraphs-starting-with-**Bold-phrase**,eg-**Security**:..,**Principal**:..)
FMT:🚫unicode-decoration(→,curly-quotes)▸ASCII(->,straight-quotes)
```

## Composition
```
CMP:🚫fractal-summaries(every-section+subsection+doc-gets-summary)
CMP:🚫dead-metaphor(same-metaphor-5-10x)▸introduce-use-move-on
CMP:🚫historical-analogy-stacking(Apple-didn't-X.Facebook-didn't-Y.Stripe-didn't-Z.)
CMP:🚫one-point-dilution(restate-same-thesis-8x-with-different-metaphors)
CMP:🚫content-duplication(same-paragraph-twice)
CMP:🚫signposted-conclusion(In-conclusion,To-sum-up,In-summary,The-Takeaway,Final-Thoughts,Wrap-up,TL;DR-as-section-header)
CMP:🚫despite-its-challenges-formula(Despite-X,Y-faces-challenges→Despite-these-challenges-optimistic)
```
