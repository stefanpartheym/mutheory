# Initial concept

## Commands

```
mutheory fifths
mutheory fifths KEY
mutheory quiz relatives [-n N]
mutheory quiz relatives major [-n N]
mutheory quiz relatives minor [-n N]
```

## Keys

- The 12 major keys of the circle (C G D A E B F♯ D♭ A♭ E♭ B♭ F) and their relative minors.
- English note names.
- Output uses ♯ and ♭.

## Key input

Case-sensitive. Applies to quiz answers and `fifths KEY`.

- Major: uppercase letter, e.g. `G`, `F#`, `Bb`, `B♭`.
- Minor: uppercase letter with `m`, or lowercase letter without `m`, e.g. `Em` or `e`, `F#m` or `f#`.
- Sharp: `#` or `♯`. Flat: `b` or `♭`.
- Lowercase with `m` (e.g. `cm`) is invalid.

## fifths

Layout like https://www.circlefifth.com/app: majors on the outer ring, relative minors on the inner ring, C at the top, fifths clockwise. Colored output.

Without KEY, nothing is highlighted. With KEY:

| Color | Keys                       | `G`  | `Em`   |
| ----- | -------------------------- | ---- | ------ |
| hl1   | the key                    | G    | Em     |
| hl2   | its relative               | Em   | G      |
| hl3   | its neighbours on the ring | C, D | Am, Bm |

## quiz relatives

- Asks for the relative of a random key. Without `major` or `minor`, both directions are mixed.
- `-n` sets the number of questions, default 10.
- Free text input. Only the spelling shown on the circle is correct.
- Invalid input prints `X is not a valid key` and asks again. It does not count as an answer.
- After each answer: correct or wrong, plus the correct answer.
- At the end: score and a list of all questions with the given and the correct answer.
- Later: Multiple choice mode.
