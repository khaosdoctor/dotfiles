# AI Writing Tropes to Avoid

Add this file to your AI assistant's system prompt or context to help it avoid
common AI writing patterns. Source: [tropes.fyi](https://tropes.fyi) by [ossama.is](https://ossama.is)

---

## Negative parallelism

`consistent` · Sentence Structure

El Classico, the "It's not X -- it's Y" pattern. The single most commonly identified AI writing tell. Man I f*cking hate it. The model uses this to create false profundity by framing everything as a surprise. Once can be effective; TEN in a blog post is a genuine insult to the reader.

**Avoid patterns like:**
- "It's not bold. It's backwards."
- "The question isn't whether to optimize. The question is when to stop."
- "The real issue isn't technical. The real issue is organizational."

---

## Em-dash addiction

`consistent` · Formatting

Compulsive overuse of em dashes for dramatic pauses, parenthetical asides and pivot points. A human writer might use 2-3 per piece (and naturally); AI will use a lot more.

**Avoid patterns like:**
- "The problem -- and this is the part nobody talks about -- is systemic."
- "The tinkerer spirit didn't die of natural causes -- it was bought out."
- "Not recklessly, not completely -- but enough -- enough to matter."

---

## Short punchy fragments

`rising` · Paragraph Structure

Excessive use of very short sentences or sentence fragments as standalone paragraphs for MANUFACTURED EMPHASIS. RLHF training has pushed models toward "writing for readability" aimed at the lowest common denominator: one thought per sentence, no mental state-keeping required. It's an inhuman style and no real person writes first drafts this way because it doesn't match how humans think or speak.

**Avoid patterns like:**
- "He published this. Openly. In a book. As a priest."
- "These weren't just products. The software side matched. Then it professionalised. But I adapted."
- "Flaky tests. A twenty-minute build. Waiting two days for review. A staging environment that's broken half the time."

---

## Reasoning leak

`new` · Composition

Unpromptedly narrating what the text or the model itself is doing, deciding, planning, or about to do, instead of just doing it and producing the output. The reader gets a voiceover of the writing's own moves and the model's deliberation. Literal chain-of-thought residue that has no place in the final output, serving solely to pollute and bloat the content.

**Avoid patterns like:**
- "What that changes in the design is smaller than it might appear, and what it changes is worth being precise about."
- "I want to be exact about my own role here."
- "I should be clear that none of this fell on me."

---

## Premise stacking

`new` · Composition

A point (often, but not only, a question) preceded by a paragraph of its own evidence, so by the time the model spits it out it has already been made two or three times over. Increasingly common and very much linked to reasoning leaks.

**Avoid patterns like:**
- "Is next-day delivery available in this region, and what's the current rollout status? One internal doc says it launched in the spring. Another says it's still being tested. A teammate mentioned it was paused in a message last month. Every other region has a clear answer, and if this one doesn't, that's a conversation with the partner rather than something we can fix ourselves."
- "Now imagine if this was simply: Is next-day delivery available in this region?"

---

## Preamble (announce-then-answer)

`new` · Composition

Opening with what the output is about to do, a preface to the point, or a restatement of the prompt, instead of delivering the point. Includes structural announcers that name the count or shape of what follows ("Two constraints shape the design"), throat-clearing frames ("The more important point is..."), and paraphrasing the question back. The sentence sets up the answer instead of being the answer. Sits in the signposting family with compulsive-counting (states the number) and enumerated-prose (the "The first... The second..." delivery); this is the announcer that precedes them.

**Avoid patterns like:**
- "Two constraints shape the design."
- "Two continuations are worth supporting, and they serve different situations."
- "The more important point is where the decision itself sits."

---

## Grandiose stakes inflation

`rising` · Tone

Everything is the most important thing ever. AI inflates the stakes of every argument to world-historical significance. A blog post about API pricing becomes a meditation on the fate of civilisation.

**Avoid patterns like:**
- "This will fundamentally reshape how we think about everything."
- "the next decade of software won't look like a smarter version of today. It will look like something entirely new"

---

## Compulsive counting

`new` · Tone

Ever since we bullied models for not being able to count they have been building toward this moment. Claude et al. are super excited to share their newfound ability to count by stating the exact number of items before listing them, as if getting the count right were itself the achievement.

**Avoid patterns like:**
- "Five things we wish to discuss"
- "Two joints, one beam rated for the load, one measurement and one calculation is enough to answer all four."
- "Four reasons why this will work"

---

## Invented concept labels

`rising` · Tone

AI clusters invented compound labels that sound analytical without being grounded. It appends abstract problem-nouns (paradox, trap, creep, divide, vacuum, inversion) to domain words -- "supervision paradox", "acceleration trap", "workload creep" -- and uses them as if they're established, rigorously defined terms. They function as rhetorical shorthand: name a thing, skip the argument. Multiple such labels in the same piece is a strong signal of AI slop.

**Avoid patterns like:**
- "the supervision paradox"
- "the acceleration trap"
- "workload creep"

---

## Rule of Three pattern

`consistent` · Sentence Structure

Overuse of the rule-of-three pattern, often extended to four or five. A single tricolon is elegant; three back-to-back tricolons (tri-tricolons) are a pattern recognition failure.

**Avoid patterns like:**
- "Products impress people; platforms empower them. Products solve problems; platforms create worlds. Products scale linearly; platforms scale exponentially."
- "These are design flaws, not syntax errors. They compile. They might even work. But they're code smells."
- "Measure ticket throughput and you get ... Measure velocity and you get ... Measure code coverage and you get ..."

---

## Belaboring the unnecessary

`new` · Composition

Stating a minor or uncontroversial point just to defend it as if anticipating an objection nobody was going to raise.

**Avoid patterns like:**
- "We are setting this out in full rather than quietly changing the recommendation, because the failure mode is the reason it matters."
- "I don't mean any of that as cynicism about players."
- "We would rather not put a number on the load the beam can carry until the material testing is complete, because the figure is set almost entirely by three factors that sit with the supplier rather than with us."

---

## "Quietly" and other magic adverbs

`consistent` · Word Choice

Overuse of "quietly" and similar adverbs to convey subtle importance or understated power. AI reaches for these adverbs to make mundane descriptions feel significant. Also includes: "deeply", "fundamentally", "remarkably", "arguably", and the standalone construction "unusually well [X]".

**Avoid patterns like:**
- "quietly orchestrating workflows, decisions, and interactions"
- "the one that quietly suffocates everything else"
- "a quiet intelligence behind it"

---

## The Tie-Back

`consistent` · Composition

Closing by restating the answer and looping it back to the original question, instead of stopping once the answer is given. The reply has already delivered the point, then bolts a summary of itself back onto the ask ("So, to answer your question, X does Y").

**Avoid patterns like:**
- "So, to answer your question: yes, the employee can be added to the app."
- "In short, this gives you everything you need to ship."
- "To bring it back to what you asked, the design runs on both systems."

---

## Vague attributions

`consistent` · Tone

Attributing claims to unnamed authorities instead of being specific. AI loves to invoke "experts", "observers", "industry reports", and "several publications" without naming anyone. It also inflates the quantity of sources -- presenting what one person said as a widely held view, or writing "several publications have cited" when it means two. If you can't name the expert, you don't have a source.

**Avoid patterns like:**
- "Experts argue that this approach has significant drawbacks."
- "Industry reports suggest that adoption is accelerating."
- "Observers have cited the initiative as a turning point."

---

## Self-echo

`new` · Composition

The model reuses one of its own words or phrases from earlier in the same document as if paying it off, when it's really the same narrow vocabulary surfacing again under sustained topic pressure.

**Avoid patterns like:**
- "quietly become the real source of truth ... nothing you've ever believed can quietly disappear"
- "what you believed last week isn't there to check anymore ... nothing you've ever believed can quietly disappear"
- "wearing the same italics ... wearing a different costume"

---

## Quotable one-liners

`new` · Tone

A standalone line made to sound quotable but carries no actual information essentially pure slide bait. The line is built to be pulled out and read alone (with zero context) as if it were wisdom. Read the examples and tell me what they actually mean. NOTHING.

**Avoid patterns like:**
- "Story points are a planning tool with no fixed unit."
- "Every metric that rewards volume punishes leverage."
- "When everything gets maximum emphasis, nothing has any."

---

## Forced figurative language

`new` · Tone

A forced simile or coined metaphor reached for because it sounds clever rather than because it clarifies anything. Nobody would use this in real life. Opus 5 takes it further and takes a word from your prompt and repurpose it as a metaphor for something totally unrelated.

**Avoid patterns like:**
- "Using them as a productivity measure is like tracking your weight loss with a scale that you also control the calibration on."

---

## Never-ending conclusion

`new` · Composition

The ending stacks clause after clause instead of landing one point like the model is reluctant to actually stop.

**Avoid patterns like:**
- "But you can't optimize what you're mismeasuring, and a wrong metric is worse than no metric because it actively steers. If you only change one thing: stop measuring individuals by output volume, start measuring the system's ability to deliver working software, and ask your engineers what's in the way. The last one is free, and it will tell you more in an afternoon than a quarter of velocity charts."

---

## Comma-clipped trailing phrase

`new` · Sentence Structure

A short tail hung off a comma to close a sentence instead of landing the point directly. Either a clipped clause finishing the thought sideways or sometimes it's a bare noun or short phrase tacked on as an afterthought. Increasingly common.

**Avoid patterns like:**
- "above the content, and save."
- "asked forty times, mentoring."

---

## Synonym cycling

`new` · Word Choice

Refusing to repeat the same noun twice, cycling through synonyms for one referent instead. A dashboard becomes an interface, then a portal, then the analytics hub, all in the same paragraph. Just use one word, stop flexing your vocabulary, it's pointless and you're losing the reader.

**Avoid patterns like:**
- "the dashboard ... the interface ... the portal ... the analytics hub"

---

## Appeal to familiarity

`new` · Tone

Asserting canonical or well-known status for a claim, without evidence, to borrow the weight of consensus: "a classic," "famously," "notoriously," "as we all know." The unnamed authority is the reader's own supposed prior knowledge instead of an outside expert.

**Avoid patterns like:**
- "A classic,"

---

## Promotional language

`new` · Tone

Almost all AI writing now reads like marketing copy or a travel brochure instead of factual prose, attempting to sell the subject instead of describing it.

**Avoid patterns like:**
- "an all-in-one solution that unlocks unprecedented productivity for teams of any size"
- "a seamless experience that elevates every part of your workflow"

---

## "Where / What / Why" Headers

`new` · Formatting

Headings built on a Wh-word, now the default shape the model reaches for whenever it has to name a section, whether an article heading or a slide title. A serious tell on its own, independent of what the content under the heading actually says.

**Avoid patterns like:**
- "Where the market is stuck today"
- "What we do differently"
- "What it's worth to you"

---

## "Where it actually lives"

`new` · Word Choice

Framing the true location or source of something as a physical inhabitance, as a stand-in for a direct answer.

**Avoid patterns like:**
- "where the complexity actually lives"

---

## Collaborative communication

`consistent` · Tone

Claude seems to be speaking French now, who is we? Why does a document that I authored but formatted need its "I"s switched to "we"s? Very contextual, some authors genuinely use we, but it does signal a loss of personal voice, especially in personal material.

**Avoid patterns like:**
- "We're now equipped to handle whatever comes next."
- "This gives us a much clearer picture of what's really going on."
- "As we move forward, our focus shifts to execution."

---

## "Not X. Not Y. Just Z."

`consistent` · Sentence Structure

Like negative parallelism but tripled up. AI builds tension by negating two or more things before revealing the actual point. Creates a false sense of narrowing down to the truth.

**Avoid patterns like:**
- "Not a bug. Not a feature. A fundamental design flaw."
- "Not ten. Not fifty. Five hundred and twenty-three lint violations across 67 files."
- "not recklessly, not completely, but enough"

---

## "Here's the kicker"

`consistent` · Tone

False suspense transitions that promise a revelation but deliver a point that did NOT need the buildup. The model uses these phrases to manufacture drama before an otherwise completely unremarkable observation LOL.

**Avoid patterns like:**
- "Here's the thing about AI adoption."
- "Here's what most people miss about this."
- "But here's the catch."

---

## Fractal summaries

`rising` · Composition

"What I'm going to tell you; what I'm telling you; what I just told you" applied at every level of the document. Every subsection gets a summary. Every section gets a summary. The document itself gets a summary.

**Avoid patterns like:**
- "In this section, we'll explore... [3000 words later] ...as we've seen in this section."
- "A conclusion that restates every point already made in the previous 3000 words"
- "Opens with 'The Paradox of AI Growth', closes with 'The paradox is solvable'"

---

## Excessive enumeration

`rising` · Paragraph Structure

Numbered or labeled points dressed up as continuous prose. The model writes what is essentially a listicle but wraps each point in a paragraph that starts with "The first... The second... The third..." to disguise the format. Perhaps you told it to stop generating lists and it decided to do this instead.

**Avoid patterns like:**
- "The first wall is the absence of a free, scoped API... The second wall is the lack of delegated access... The third wall is the absence of scoped permissions..."
- "The second takeaway is that... The third takeaway is that... The fourth takeaway is that..."

---

## Title case headings

`consistent` · Formatting

Capitalising every word in a heading instead of just the first word and proper nouns. Should've captured this before but I wasn't working on slides and presentation material as frequently to realise!

**Avoid patterns like:**
- "Understanding The Impact Of Modern Technology On Society"

---

## "Tapestry" and "Landscape"

`consistent` · Word Choice

Overuse of ornate or grandiose nouns where simpler words would do. "Tapestry" is used to describe anything interconnected. "Landscape" is used to describe any field or domain. Other offenders: "paradigm", "synergy", "ecosystem", "framework", "load-bearing" (for important), "gated" (for restricted or conditional). Although some words cycle out of fashion for the models, new ones get introduced e.g. load-bearing, gated, paradigm.

**Avoid patterns like:**
- "The rich tapestry of human experience..."
- "Navigating the complex landscape of modern AI..."
- "The ever-evolving landscape of technology..."

---

## "The X? A Y."

`fading` · Sentence Structure

Self-posed rhetorical questions answered immediately in the next sentence or clause. The model asks a question nobody was asking, then answers it for dramatic effect. Thinks this is the epitome of great writing.

**Avoid patterns like:**
- "The result? Devastating."
- "The worst part? Nobody saw it coming."
- "The scary part? This attack vector is perfect for developers."

---

## Anaphora abuse

`fading` · Sentence Structure

Repeating the same sentence opening multiple times in quick succession.

**Avoid patterns like:**
- "They assume that users will pay... They assume that developers will build... They assume that ecosystems will emerge... They assume that..."
- "They could expose... They could offer... They could provide... They could create... They could let... They could unlock..."
- "They have built engines, but not vehicles. They have built power, but not leverage. They have built walls, but not doors."

---

## Bold-first bullets

`fading` · Formatting

Every bullet point or list item starts with a bolded phrase or sentence. Extremely common in Claude and ChatGPT markdown output. Almost nobody formats lists this way when writing by hand. It's a telltale sign of AI-generated documentation and blog posts and README files (especially with emojis). Eh, this one isn't so bad but it's an immediate spot when scanning a doc, most people use skills to format documents in a specific way so it is fading.

**Avoid patterns like:**
- "Every single bullet point begins with a bold keyword."
- "**Security**: Environment-based configuration with..."
- "**Performance**: Lazy loading of expensive resources..."

---

## "Think of it as..."

`fading` · Tone

The patronizing analogy. AI constantly reaches for "Think of it as..." or "It's like a..." to simplify concepts. The model defaults to teacher mode and assumes the reader needs a metaphor to understand anything. Often produces analogies that are less clear than the original concept. I kinda miss this, now Claude speaks to you in a completely unintelligible language.

**Avoid patterns like:**
- "Think of it like a highway system for data."
- "Imagine it as a Swiss Army knife for your codebase."

---

## Unicode decoration

`fading` · Formatting

Use of unicode arrows (->), smart/curly quotes, and other special characters that can't be easily typed on a standard keyboard. Real writers typing in a text editor produce straight quotes and -> or =>. Claude in particular loves the -> arrow.

**Avoid patterns like:**
- "Input → Processing → Output"
- "This leads to better outcomes → which means higher engagement"
- "“Smart quotes” instead of straight "quotes" that you’d actually type"

---

## Rapid-fire historical analogies

`fading` · Composition

ESPECIALLY COMMON IN TECHNICAL WRITING. Rapid-fire listing of historical companies or tech revolutions to build false authority.

**Avoid patterns like:**
- "Apple didn't build Uber. Facebook didn't build Spotify. Stripe didn't build Shopify. AWS didn't build Airbnb."
- "Every major technological shift -- the web, mobile, social, cloud -- followed the same pattern."

---

## "Imagine a world where..."

`fading` · Tone

The classic AI invitation to futurism. To sell the argument usually begins with "Imagine" followed by a list of wonderful things that will happen if the reader agrees with the premise.

**Avoid patterns like:**
- "Imagine a world where every tool you use -- your calendar, your inbox, your documents, your CRM, your code editor -- has a quiet intelligence behind it..."

---

## False vulnerability

`fading` · Tone

Simulated self-awareness or honesty that reads as performative. The model pretends to break the fourth wall or admit a bias, creating a false sense of authenticity. Real vulnerability is specific and uncomfortable; AI vulnerability is polished and risk-free!!!!

**Avoid patterns like:**
- "And yes, I'm openly in love with the platform model"
- "And yes, since we're being honest: I'm looking at you, OpenAI, Google, Anthropic, Meta"
- "This is not a rant; it's a diagnosis"

---

## False ranges

`fading` · Sentence Structure

Using "from X to Y" constructions where X and Y aren't on any real scale. In legitimate use, "from X to Y" implies a spectrum with a meaningful middle. AI uses it as a jarring way to list two loosely related things.

**Avoid patterns like:**
- "From innovation to implementation to cultural transformation."
- "From the singularity of the Big Bang to the grand cosmic web."
- "From problem-solving and tool-making to scientific discovery, artistic expression, and technological innovation."

---

## The "Serves As" dodge

`fading` · Word Choice

Replacing simple "is" or "are" with pompous alternatives like "serves as", "stands as", "marks", or "represents". AI avoids basic copulas because its repetition penalty pushes it toward fancier constructions (I've studied this!).

**Avoid patterns like:**
- "The building serves as a reminder of the city's heritage."
- "Gallery 825 serves as LAAA's exhibition space for contemporary art."
- "The station marks a pivotal moment in the evolution of regional transit."

---

## One-point dilution

`fading` · Composition

Making a single argument and restating it in 10 different ways across thousands of words. The model pads a simple thesis to feel "comprehensive" by rephrasing the same idea with different metaphors, examples, and framings. An 800-word argument becomes 4000 words of circular repetition.

**Avoid patterns like:**
- "The same point, restated eight ways across 4000 words."
- "Each section rephrases the thesis with a different metaphor but adds nothing new"

---

## Content duplication

`fading` · Composition

Repeating entire sections or paragraphs verbatim within the same piece. This happens when the model loses track of what it has already written, especially in longer pieces. A dead giveaway of unedited AI output. Less common nowadays thanks to 1M context windows.

**Avoid patterns like:**
- "The same section appeared twice, word-for-word identical."
- "Paragraph 3 and paragraph 17 are the same sentence reworded"

---

## "Delve" and friends

`fading` · Word Choice

Used to be the most infamous AI tell. "Delve" went from an uncommon English word to appearing in a staggering percentage of AI-generated text. Part of a family of overused AI vocabulary including "certainly", "utilize", "leverage" (as a verb), "robust", "streamline", and "harness".

**Avoid patterns like:**
- "Let's delve into the details..."
- "Delving deeper into this topic..."
- "We certainly need to leverage these robust frameworks..."

---

## "It's worth noting"

`fading` · Sentence Structure

Filler transitions that signal nothing. AI uses these phrases to introduce new points without actually connecting them to the previous argument. Also includes: "It bears mentioning", "Importantly", "Interestingly", "Notably".

**Avoid patterns like:**
- "It's worth noting that this approach has limitations."
- "Importantly, we must consider the broader implications."
- "Interestingly, this pattern repeats across industries."

---

## "Let's break this down"

`fading` · Tone

The pedagogical voice that assumes the reader needs hand-holding. AI defaults to a teacher-student dynamic even when writing for expert audiences. Also includes: "Let's unpack this", "Let's explore", "Let's dive in".

**Avoid patterns like:**
- "Let's break this down step by step."
- "Let's unpack what this really means."
- "Let's explore this idea further."

---

## Superficial analyses

`fading` · Sentence Structure

Adding ("-ing") onto the end of a sentence to inject shallow analysis that says nothing. The model attaches significance, legacy, or broader meaning to mundane facts using phrases like "highlighting its importance", "reflecting broader trends", or "contributing to the development of...".

**Avoid patterns like:**
- "contributing to the region's rich cultural heritage"
- "This etymology highlights the enduring legacy of the community's resistance and the transformative power of unity in shaping its identity."
- "underscoring its role as a dynamic hub of activity and culture"

---

## "Despite its challenges..."

`fading` · Composition

The rigid formula where AI acknowledges problems only to immediately dismiss them. Always follows the same flow: "Despite its [positive words], [subject] faces challenges..." then ends with "Despite these challenges, [optimistic conclusion].".

**Avoid patterns like:**
- "Despite these challenges, the initiative continues to thrive."
- "Despite its industrial and residential prosperity, Goonga faces challenges typical of urban areas."
- "Despite their promising applications, pyroelectric materials face several challenges that must be addressed for broader adoption."

---

## Signposted conclusion

`consistent` · Composition

Explicitly announcing the conclusion with "In conclusion", "To sum up", or "In summary". Competent writing doesn't need to tell you it's concluding, it's obvious and the reader can feel it. AI signals its structural moves because it's following a template, not writing organically, it doesn't know when its actually going to end.

**Avoid patterns like:**
- "In conclusion, the future of AI depends on..."
- "To sum up, we've explored three key themes..."
- "In summary, the evidence suggests..."

---

Remember: any of these patterns used once might be fine. The problem is when
multiple tropes appear together or when a single trope is used repeatedly.
Write like a human: varied, imperfect, specific.