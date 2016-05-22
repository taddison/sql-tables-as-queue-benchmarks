# In-Memory Implementations

1. Implement with native enqueue/dequeue procs over an in-memory table. As CTEs are not supported we have to get the row to delete and then delete it, leaving us open to concurrency exceptions (write/write conflict throws error 41302 - see [isolation levels and conflicts](https://msdn.microsoft.com/en-us/library/mt668435.aspx#Anchor_3)).
