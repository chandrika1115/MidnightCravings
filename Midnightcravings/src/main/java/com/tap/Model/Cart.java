package com.tap.Model;

import java.util.HashMap;
import java.util.Map;

public class Cart {
    private Map<Integer, CartItem> items;
    private int restaurantId; // Tracks the single active restaurant ID

    public Cart() {
        this.items = new HashMap<>();
        this.restaurantId = 0;
    }

    public void addItem(CartItem item) {
        int menuId = item.getMenuId();
        this.restaurantId = item.getRestaurantId();
        items.put(menuId, item);
    }

    public void removeItem(int menuId) {
        items.remove(menuId);
        if (items.isEmpty()) {
            this.restaurantId = 0;
        }
    }

    public void clear() {
        items.clear();
        this.restaurantId = 0;
    }

    public Map<Integer, CartItem> getItems() {
        return items;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }
}
