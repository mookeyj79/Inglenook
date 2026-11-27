# Evening reading

A short note for the fire. The wood is stacked by the door, see [[Kindling]].

## Tonight

- [x] Bring in the logs
- [ ] Finish the chapter #reading

> [!note] Keep the damper open
> A little air keeps the smoke going up the chimney.

### A small script

```python
def warm(room: str, logs: int = 3) -> bool:
    # one more log on the fire
    return logs > 0 and room == "library"
```
