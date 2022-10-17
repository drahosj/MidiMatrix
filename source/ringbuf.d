module ringbuf;

shared struct Ringbuf(T, size_t size) {
    size_t head;
    size_t tail;
    T[size] buffer;

    bool full()
    {
        return (head + 1) % size == tail;
    }

    bool empty()
    {
        return head == tail;
    }

    int put(T t)
    {
        if (full) {
            return -1;
        }

        /* TODO: Wrap in check for interrupt level that direction is sane */
        buffer[head] = cast(shared) t;
        head = (head + 1) % size;
        
        return 0;
    }

    int take(out T t)
    {
        if (empty) {
            return -1;
        }

        /* TODO: Wrap in check for interrupt level that direction is sane */
        t = cast(T) buffer[tail];
        tail = (tail + 1) % size;

        return 0;
    }
};

version (runTest)
{
    int main() {
        import std.stdio;
        
        auto buf = Ringbuf!(int, 5)();
        int t = 1;
        assert(buf.take(t), "Initial take should fail");
        assert(t == 0, "t should be set to init");

        assert(buf.empty, "Initially empty");
        assert(!buf.put(1), "put 1");
        assert(!buf.put(2), "put 2");
        assert(!buf.put(3), "put 3");
        assert(!buf.put(4), "put 4");
        assert(buf.full, "Now full");
        assert(buf.buffer == [1, 2, 3, 4, 0]);
        assert(!buf.take(t), "take 1");
        assert(t == 1, "t == 1");
        assert(!buf.full, "not full after one take");
        assert(!buf.put(5), "put 5");
        assert(buf.full, "full after put 5");
        assert(buf.put(6), "put should fail");
        assert(buf.buffer == [1, 2, 3, 4, 5]);
        assert(!buf.take(t), "take 1");
        assert(t == 2, "t == 2");
        assert(!buf.put(10), "put 10");
        assert(buf.full, "full again");
        assert(!buf.take(t), "take 2");
        assert(t == 3, "t == 3");
        assert(!buf.take(t), "take 3");
        assert(t == 4, "t == 4");
        assert(!buf.take(t), "take 4");
        assert(t == 5, "t == 5");
        assert(!buf.take(t), "take 5");
        assert(t == 10, "t == 10");
        assert(buf.empty, "Empty after 5 takes");
        assert(!buf.put(20), "put 20");
        assert(!buf.put(30), "put 30");
        assert(!buf.put(40), "put 40");
        assert(!buf.put(50), "put 40");
        assert(buf.full, "Ends full");

        writeln("ringbuf.d: PASSED");
        return 0;
    }
}
