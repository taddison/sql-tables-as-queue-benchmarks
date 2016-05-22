# In-Memory Implementations

1. Implement with native enqueue/dequeue procs over an in-memory table. As CTEs are not supported we have to get the row to delete and then delete it, leaving us open to concurrency exceptions (write/write conflict throws error 41302 - see [isolation levels and conflicts](https://msdn.microsoft.com/en-us/library/mt668435.aspx#Anchor_3)).
2. Outer (non-native) proc which wraps the inner (native) proc in a try-catch with retry logic.  If 41302 is thrown the inner call is retried instantly (no exponential backoff, random jitter, etc.).  Attempts capped at 20 (arbitrarily chosen).
