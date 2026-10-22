# By Dee++

## 1. Ideation and Brainstorming Notes

During our ideation session, our group looked into the common daily problems of small businesses in the Philippines like carinderias, barbershops, and sari-sari stores. We brainstormed three main directions before deciding on our final project.

---

### Idea 1: Simple Financial and Recipe Tracker for Small Shops

What it is:
A simple sales and expense tracker for small food shops and vendors who usually don't track numbers until they are already losing money. Most small business owners only realize there is a problem when it becomes an emergency.

Features we considered:

- Simple tap-to-record counter: You set an item and its price. Tap plus to add a sale, tap minus if you mis-tapped or if an order was cancelled.
- Item breakdown: Tapping an item shows how much it costs to make based on ingredients versus how much it sells for.
- Underperforming item alert: Shows which items are not making money or are moving too slowly so the owner can remove or change them.
- Weekly and monthly summaries instead of overwhelming daily logs.
- Future scaling: Connecting to barcode scanners or existing POS systems.

---

### Idea 2: Inflation Combat Calculator

What it is:
A tool to help small food businesses deal with rising ingredient costs without scaring away their regular customers (suki) with big price jumps.

Features we considered:

- Recipe cost calculator: Shows the owner how much each dish costs to prepare today compared to last month.
- Suggesting ways to soften price increases:
  - Slight ingredient adjustments (for example, reducing chicken from 22 grams to 18 grams in a dish so the price can stay the same).
  - Product bundling (combining a meal with a drink at a small discount instead of increasing the meal price directly).
  - Calculating the safest price adjustment that covers costs without losing buyers.
  - Suggesting which bulk ingredients to buy or cut down on depending on sales speed.

---

## 2. Current most feasible idea (for now)

### The Main Idea

Basically a digital version of the buzzers you get when ordering at places like Jollibee, but it runs on the customer's own phone.

Instead of waiting inside a cramped, hot shop or losing walk-in customers who leave because the line looks too long, customers get a virtual buzzer on their phone that rings and vibrates when it is almost their turn.

---

### The Problem It Solves

1. People leave when they see long lines (Walk-in loss):
   For barbershops, hair salons, small clinics, and laundromats, walk-ins are their main income. When someone walks in and sees 4 people already waiting, they often say "ang haba ng pila, sa iba na lang" and walk out. Small shops lose around 20% to 30% of their daily sales just because people do not want to wait around doing nothing.

2. Physical buzzers are too expensive:
   Big restaurant chains use plastic buzzer sets with charging bases, but these cost 15,000 to 35,000 pesos. That is 1 or 2 months of profit for a small shop. They also break easily when dropped on tiles or customers forget to return them.

3. Waiting time is wasted time:
   Sitting on a plastic monobloc chair for 40 minutes scrolling on Facebook helps nobody. If customers knew they had 30 minutes, they could step out, grab a snack, or buy something nearby.

4. SMS notifiers cost too much:
   Sending SMS updates costs 50 centavos to 1 peso per text message. For a shop with 40 to 50 customers a day, that adds up to over 1,000 pesos a month just on texts.

---

### Key Features

1. Digital Buzzer on Phone:

- The customer opens a link and sees a round buzzer on their screen with lights and their queue number.
- Blue screen: In line. Shows how many people are ahead and roughly how many minutes left.
- Amber pulsing: Almost your turn (1 person ahead). Vibrates the phone so the customer knows to start walking back.
- Green screen: Now serving. Tells the customer which station or barber to go to (for example: "Chair 1 with Kuya Dennis").

2. "Papunta Na Ako" (I am on my way) button:

- When the buzzer alerts the customer, they can tap a button saying they are heading back.
- The shop owner sees this on their counter screen so they do not skip the person's turn.

3. Shop Owner Dashboard:

- Simple counter view for the owner or cashier.
- Shows who is in line and who is currently being served at each station.
- One tap to call the next customer or alert someone that they are next.
- One tap to add a walk-in customer.

---

### The current Tech Stack we plan (based on what we know)

- Frontend: Flutter (works across web and mobile)
- Backend: Java Spring Boot (handles the live queue updates and notifications)
