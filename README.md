# EZPOS - Point of Sale & Inventory Management System

EZPOS is a mobile-based Point of Sale (POS) and inventory management application customized for retail use (such as the Rhea Chen Store). The app helps streamline daily store transactions, manage stock levels, calculate sales analytics, and generate product barcodes.

---

## Table of Contents
1. [User Flow & Application Features](#user-flow--application-features)
   - [1. Authentication](#1-authentication)
   - [2. Point of Sale (POS)](#2-point-of-sale-pos)
   - [3. Checkout & Payment](#3-checkout--payment)
   - [4. Stock & Inventory Management](#4-stock--inventory-management)
   - [5. Product Details & Barcode Generation](#5-product-details--barcode-generation)
   - [6. Sales History & Analytics](#6-sales-history--analytics)
2. [Tech Stack (Suggested)](#tech-stack-suggested)
3. [Installation & Setup](#installation--setup)

---

## User Flow & Application Features

### 1. Authentication

#### Login Page (Sign In)
The entry point of the application requires store administrators or staff to authenticate. 
* Supports traditional login using **Email** and **Password**.
* Includes a **Google Sign-In** option for faster, single-tap authentication.
* Features a loading state screen during external authentication processes.

| Login Screen | Google Authentication Loading |
| :---: | :---: |
| ![Login Page](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\08854b9d-33f2-46e7-809e-4a422e67c3d8.jpg) | ![Google Sign-In](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\0368d515-93a0-4121-a945-d6991a8f35d2.jpg) |

#### Registration Page (Sign Up)
New staff or store administrators can register by creating an account. The registration form collects:
* Full Name
* Email Address
* Contact Number
* Password

![Sign Up Page](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\aa166564-2b66-43de-82f1-b603aff93bec.jpg)

---

### 2. Point of Sale (POS)

Once logged in, users are directed to the main **POS Dashboard**, which serves as the core checkout interface.
* **Product Selection:** Easily view and add items to the cart.
* **Quantity Controls:** Increase or decrease item quantities directly from the list using simple `+` and `-` controls.
* **Barcode Scanning & Search:** Quickly search for items manually or trigger the device camera to scan barcodes.
* **Total Calculation:** Real-time updating of the total amount at the bottom of the screen before proceeding to checkout.

![POS Page](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\00c58e4c-b1eb-4d5a-bda8-5a2fd3fac21b.jpg)

---

### 3. Checkout & Payment

#### Checkout Screen
After clicking checkout, the user is redirected to the payment screen:
* **Order Summary:** Displays an itemized list of products, quantities, individual pricing, and the total cost.
* **Cash Handled:** Input field to enter the cash amount received from the customer.
* **Change Calculation:** Automatically calculates and displays the exact change due to the customer in real-time.

#### Payment Confirmation
Upon pressing the payment button, a success modal overlays the screen confirming the completed transaction and total amount, with a **New Transaction** button to clear the cart and start over.

| Checkout Screen | Payment Confirmation |
| :---: | :---: |
| ![Checkout Screen](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\bcde57c4-bd6b-4238-bd30-7f912f8efc3a.jpg) | ![Success Dialog](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\e9a0a7b0-3c6d-41a6-80fc-043c880601ce.jpg) |

---

### 4. Stock & Inventory Management

#### Inventory Dashboard
The **Stock** tab provides a quick, high-level overview of the store’s current inventory.
* **Total Items & Alert Cards:** Visual counters for the total number of unique items and any items currently experiencing "Low Stock."
* **Search Function:** A dedicated search bar to quickly filter products.
* **Stock List:** Displays each product’s current stock quantity (e.g., "Red Horse: 11 pcs").

#### Add New Item
The **Add Item** button opens a modal form allowing staff to expand the store inventory:
* Image upload capability.
* Input fields for **Product Name**, **Category** selection, **Price**, and **Initial Stock**.

| Stock Inventory | Add Item Modal |
| :---: | :---: |
| ![Inventory Page](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\c5d63a16-5471-47a4-95b5-daa90046b2b3.jpg) | ![Add Item Modal](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\ae6bffe8-fcb1-49a7-aba5-c8102c4057cb.jpg) |

---

### 5. Product Details & Barcode Generation

Tapping on any product from the inventory list opens its detailed card:
* **Item Info:** Displays the product name, category, price, and current stock quantity.
* **Automatic Barcode:** Generates and displays a unique barcode along with its numeric code.
* **Operational Actions:**
  - **Share / Print:** Share or print the barcode label directly from the mobile device.
  - **Edit / Delete:** Easily modify product details or remove items from the database entirely.

| Coke Details | Red Horse Details |
| :---: | :---: |
| ![Coke Barcode Details](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\0299c904-ec05-4271-a262-5c23e15002d4.jpg) | ![Red Horse Barcode Details](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\38ac1016-7fef-42a2-9fec-216fb5e1995f.jpg) |

---

### 6. Sales History & Analytics

The **History** tab compiles past transaction data to help track store performance.
* **Revenue Overview:** Displays **Total Revenue** and **Transaction Count (TXN Count)** at the top.
* **Sales Feed:** A chronological timeline of completed transactions showing the date, exact timestamp, total amount, and a receipt icon for reference.

![Sales History Page](C:\Users\Administrator\Desktop\CCE106%20SIR%20VELEZ\PICTURES%20FINAL\5b7f49c0-1e86-4195-be8f-b6e18f3243fb.jpg)

---

## Tech Stack (Suggested)

* **Frontend Framework:** Flutter / React Native (for cross-platform mobile delivery) or Native Android (Kotlin/Java)
* **Backend Database:** Firebase (Firestore & Authentication) or Supabase (for real-time database and user authentication)
* **Barcode Library:** Barcode generation and scanning libraries compatible with mobile camera integrations

---

## Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/ezpos.git
   cd ezpos
