package com.example.inventory;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class ItemTest {

    @Test
    void describesTheItem() {
        assertEquals("Item{name=bolt, quantity=12}", new Item("bolt", 12).toString());
    }
}
