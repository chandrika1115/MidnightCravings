
package com.tap.Model;

import java.math.BigDecimal;

public class RestaurantOrderItem {

    private int menuId;
    private String itemName;
    private int quantity;
    private BigDecimal itemTotal;

    public RestaurantOrderItem(int menuId, String itemName,
                               int quantity, BigDecimal itemTotal) {
        this.menuId = menuId;
        this.itemName = itemName;
        this.quantity = quantity;
        this.itemTotal = itemTotal;
    }

    public int getMenuId() {
        return menuId;
    }

    public String getItemName() {
        return itemName;
    }

    public int getQuantity() {
        return quantity;
    }

    public BigDecimal getItemTotal() {
        return itemTotal;
    }
}
