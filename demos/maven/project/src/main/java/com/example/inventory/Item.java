package com.example.inventory;

import com.google.common.base.Objects;

public final class Item {

    private final String name;
    private final int quantity;

    public Item(String name, int quantity) {
        this.name = name;
        this.quantity = quantity;
    }

    public String name() {
        return name;
    }

    public int quantity() {
        return quantity;
    }

    @Override
    public String toString() {
        return Objects.toStringHelper(this)
                .add("name", name)
                .add("quantity", quantity)
                .toString();
    }
}
