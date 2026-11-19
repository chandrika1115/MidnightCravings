
package com.tap.Model;

public class CartItem {
    private int menuId;
    private int restaurantId;
    private String name;
    private int quantity;
    private double price;
    private String imagePath;

    public CartItem(int menuId, int restaurantId, String name,
                    int quantity, double price) {
        this.menuId = menuId;
        this.restaurantId = restaurantId;
        this.name = name;
        this.quantity = quantity;
        this.price = price;
    }
    public CartItem(int menuId, int restaurantId, String name,
            int quantity, double price, String imagePath) {
this.menuId = menuId;
this.restaurantId = restaurantId;
this.name = name;
this.quantity = quantity;
this.price = price;
this.imagePath = imagePath;
}

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
}
