class FoodItem {
  final String name;
  final String image;
  final String price;
  final String category;

  FoodItem({
    required this.name,
    required this.image,
    required this.price,
    required this.category,
  });
}

List<FoodItem> foodList = [
  FoodItem(
    name: "Dosa",
    image:
        "https://media.istockphoto.com/id/2261611854/photo/homemade-multi-grain-dosa.jpg?s=612x612&w=is&k=20&c=DVcvxGJhb7rmlHbKuqOBkBFkD4Ia9vnG1AQZmoHQaPs=",
    price: "30",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Idli",
    image: "https://foodish-api.com/images/idly/idly18.jpg",
    price: "30",
    category: "breakfast",
  ),
  FoodItem(
    name: "Medu Vada",
    image:
        "https://www.secondrecipe.com/wp-content/uploads/2019/12/medu-wada-674x900.jpg",
    price: "30",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Poha",
    image:
        "https://media.istockphoto.com/id/1294024658/photo/indian-street-food-poha.jpg?s=612x612&w=is&k=20&c=SU1uIe7lXotH-sKhxtnRLbzhPw-mS-lMFGGeaVRUkW4=",
    price: "40",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Sabudana Khichdi",
    image:
        "https://media.istockphoto.com/id/1345942545/photo/sabudana-go.jpg?s=612x612&w=is&k=20&c=sM6T2UO514CMEYkwXu8_XjbUzpjIbcUIRe3zI8RYdxI=",
    price: "30",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Chole Bhature",
    image:
        "https://media.istockphoto.com/id/1328524499/photo/katlambe-chole.jpg?s=1024x1024&w=is&k=20&c=kDFZ5jYO4F6giOunqaJT6Aju7ee8CDjHMCJPBCwj2KE=",
    price: "70",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Misal Pav",
    image:
        "https://media.istockphoto.com/id/1310861635/photo/e-g-pav.jpg?s=612x612&w=is&k=20&c=OMHM4mlG3cxJhw4J-LSOmgNxSaY5f5P31UEiwVPbyM8=",
    price: "70",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Pav-Bhaji",
    image:
        "https://media.istockphoto.com/id/1205948695/photo/paav-bhaji.jpg?s=1024x1024&w=is&k=20&c=2V0yOEglnkcuo1hX2v0tA_DTlF9PWy6yWDZoPCmDzO0=",
    price: "70",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Puri-Aloo Bhaji",
    image:
        "https://media.istockphoto.com/id/952018646/photo/masala-aloo-sabzi-also-known-as-bombay-potatoes-served-with-fried-puri-or-poori-in-a-steel.jpg?s=612x612&w=is&k=20&c=rD2F4ADc8UuqP-PaiTWjGiX1fLAeOTMvKLqO7-i2cLg=",
    price: "30",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Uttapam",
    image:
        "https://media.istockphoto.com/id/1265553451/photo/south-indian-food-uttapam.jpg?s=1024x1024&w=is&k=20&c=vxsP5epoo-PFVwpVQJZjvUzIHQsHGw8LaOC8of4x3GQ=",
    price: "30",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Masala Dosa",
    image:
        "https://images.pexels.com/photos/12392915/pexels-photo-12392915.jpeg",
    price: "40",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Chapathi-paneer gravy ",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOR5AeJHLbDfyzoilpH73h3nUYwLrTH7l0aw&s",
    price: "40",
    category: "Breakfast",
  ),
  FoodItem(
    name: "Veg Pulav ",
    image:
        "https://images.unsplash.com/photo-1751618646882-4221d5e3b1c2?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHZlZyUyMHB1bGF2fGVufDB8fDB8fHww",
    price: "60",
    category: "Lunch",
  ),
  FoodItem(
    name: "Veg Biriyani",
    image:
        "https://media.istockphoto.com/id/1292442851/photo/traditional-hyderabadi-vegetable-veg-dum-biryani-with-mixed-veggies-served-with-mixed-raita.jpg?s=2048x2048&w=is&k=20&c=c37wtHYCYKFOBkAv22hMioLVn7_eGc6VpD4yRQOSLB0=",
    price: "60",
    category: "Lunch",
  ),
  FoodItem(
    name: "Dal-Chawal ",
    image:
        "https://media.istockphoto.com/id/1421211683/photo/healthy-nutritious-indian-comfort-food-dal-chawal-thali-or-dal-rice-served-in-two-way-ceramic.jpg?s=612x612&w=is&k=20&c=zgmro2r6xZG8kJ_sTckCHEhLUBw83Yz494Hi9NgWav8=",
    price: "30",
    category: "Lunch",
  ),
  FoodItem(
    name: "Rajma-Chawal",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0l5hPzOwAdv0nuijnuzBcih4nQvLstqXJvg&s",
    price: "40",
    category: "Lunch",
  ),
  FoodItem(
    name: "Samosa ",
    image:
        "https://media.istockphoto.com/id/2148933061/photo/selective-focus-samosa-spiced-potato-filled-pastry-crispy-savory-popular-indian-snack-with.jpg?s=2048x2048&w=is&k=20&c=aTAALtTKdMxwp57zdwo1kN_5vWV9_BOOdmOLvlgO3Os=",
    price: "15",
    category: "Snacks",
  ),
  FoodItem(
    name: "Bread pakora",
    image:
        "https://media.istockphoto.com/id/1159362267/photo/bread-pakora.jpg?s=612x612&w=is&k=20&c=10Z_crgYZMix8EtsNKaQCo2kygO3FYbGSfIyuu4KBf4=",
    price: "15",
    category: "Snacks",
  ),
  FoodItem(
    name: "Vada pav",
    image:
        "https://images.pexels.com/photos/17433337/pexels-photo-17433337.jpeg",
    price: "15",
    category: "Snacks",
  ),
  FoodItem(
    name: "Kachori",
    image:
        "https://media.istockphoto.com/id/2235590451/photo/traditional-indian-kachori-with-aloo-sabzi-and-chole.jpg?s=1024x1024&w=is&k=20&c=_VL8QY6-2w_0pfSPsgmj3N7cXVgqm7sE8uwZDR12faU=",
    price: "15",
    category: "Snacks",
  ),
  FoodItem(
    name: "Hakka Noodles ",
    image:
        "https://media.istockphoto.com/id/1159004298/photo/schezwan-noodles-with-vegetables-in-a-plate.jpg?s=612x612&w=is&k=20&c=pT6fa6qNBekfXon8wNnOpegLyRKmJIbZPBkCysQM7Dc=",
    price: "50",
    category: "Chinese",
  ),
  FoodItem(
    name: "Schezwan noodles ",
    image:
        "https://images.pexels.com/photos/11762852/pexels-photo-11762852.jpeg",
    price: "60",
    category: "Chinese",
  ),
  FoodItem(
    name: "Schezwan Fried Rice ",
    image:
        "https://media.istockphoto.com/id/1292617507/photo/tasty-veg-schezwan-fried-rice-served-in-bowl-over-a-rustic-wooden-background-indian-cuisine.jpg?s=612x612&w=is&k=20&c=MMP-VDRB340ImJkcMpe_KZLIi9VWv7AD7emE2mWZXUI=",
    price: "70",
    category: "Chinese",
  ),
  FoodItem(
    name: " Manchurian",
    image:
        "https://media.istockphoto.com/id/1208083887/photo/freshly-prepared-veg-manchurian-with-a-bowl-of-fried-rice.jpg?s=612x612&w=is&k=20&c=vd067KpvneMPzHlr1pqeOuNpF5b3dfFQLlsRPubFu5k=",
    price: "50",
    category: "Chinese",
  ),
  FoodItem(
    name: " Chinese bhel",
    image:
        "https://images.unsplash.com/photo-1716535232835-6d56282dfe8a?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2hpbmVzZSUyMGJoZWx8ZW58MHx8MHx8fDA%3D",
    price: "30",
    category: "Chinese",
  ),
  FoodItem(
    name: "Tea ",
    image:
        "https://images.pexels.com/photos/18030044/pexels-photo-18030044.jpeg",
    price: "10",
    category: "Beverages",
  ),
  FoodItem(
    name: "Coffee ",
    image:
        "https://media.istockphoto.com/id/1174632449/photo/side-view-of-hot-latte-coffee-with-latte-art-in-a-ceramic-green-cup-and-saucer-isolated-on.jpg?s=612x612&w=is&k=20&c=JviXcU9eheiBlVrQSQSzFvAO2ON9ZJDQG7HRhJ_RSdA=",
    price: "10",
    category: "Beverages",
  ),
  FoodItem(
    name: "Coca Cola ",
    image:
        "https://www.shutterstock.com/image-photo/nikopol-dnepropetrovsk-regionukraine-july-15-600nw-2493143977.jpg",
    price: "10",
    category: "Beverages",
  ),
  FoodItem(
    name: "Maaza",
    image:
        "https://m.media-amazon.com/images/I/51l1hwM2THL._AC_UF894,1000_QL80_.jpg",
    price: "10",
    category: "Beverages",
  ),
  FoodItem(
    name: "limca",
    image:
        "https://mir-s3-cdn-cf.behance.net/projects/404/82e396242862729.Y3JvcCwzOTk5LDMxMjgsMCwzOQ.jpg",
    price: "10",
    category: "Beverages",
  ),
  FoodItem(
    name: "Bisleri Water Bottle ",
    image:
        "https://5.imimg.com/data5/WX/JN/ZU/SELLER-6060390/250-ml-bisleri-packaged-drinking-water.jpg",
    price: "10",
    category: "Beverages",
  ),
  FoodItem(
    name: "Chocolate milkshake ",
    image:
        "https://media.istockphoto.com/id/1338229029/photo/chocolate-milkshake-with-whipped-cream-on-a-wooden-table.jpg?s=612x612&w=is&k=20&c=jcZ191WVWAWAEbEvVqrXmJahq9x9MyWKzYq8-fM0Vv4=",
    price: "50",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: " Mango Milkshake ",
    image:
        "https://media.istockphoto.com/id/953714424/photo/mango-lassi-or-smoothie-in-big-glasses-with-curd-cut-fruit-pieces-and-blender.jpg?s=612x612&w=is&k=20&c=o4MjPIAt24gKDeQsX30kDFfUfGnO__atdL0eX5aSX6I=",
    price: "50",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Strawberry Milkshake",
    image:
        "https://media.istockphoto.com/id/1947306495/photo/strawberry-smoothie-or-milkshake-on-white.jpg?s=612x612&w=is&k=20&c=2I86pPZLvAjhd74EHuezRZWqxhgwiNv9DjMc2CfyB4M=",
    price: "50",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Watermelon juice",
    image:
        "https://media.istockphoto.com/id/485524950/photo/glass-of-fresh-watermelon-juice-on-wood.jpg?s=612x612&w=is&k=20&c=XVXMJytVX0hg8OzXz6-YFTAMHf6esHkBW-LwCb9Uu_o=",
    price: "25",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Grape juice",
    image:
        "https://media.istockphoto.com/id/171252820/photo/grape-juice.jpg?s=612x612&w=is&k=20&c=3lsZvbo5UljnNI4REkkUt1Pf6ftMOIQq8-YqZLrjimA=",
    price: "25",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Pineapple juice",
    image:
        "https://media.istockphoto.com/id/1158164118/photo/sliced-pineapple-kept-on-a-wooden-table-besides-a-glass-filled-with-pineapple-juice-and-a.jpg?s=612x612&w=is&k=20&c=wdQV78R74c-GiV9Oe7lId5ZxHIC8lmL85hdXRt37fcQ=",
    price: "25",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Cold Coffee ",
    image:
        "https://media.istockphoto.com/id/528637592/photo/homemade-coffee-cocktail-with-whipped-cream-and-liquid-chocolate.jpg?s=612x612&w=is&k=20&c=qR051xBjB7-bs10lw8_61nocDMBwNsA4w9rByZfo_ak=",
    price: "35",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Orange Juice ",
    image:
        "https://media.istockphoto.com/id/1400831765/photo/yellow-orange-fruits-and-fresh-orange-juice-squeezing-out-the-fresh-orange.jpg?s=1024x1024&w=is&k=20&c=fDTLso6tO05RqZ11cxdJ4cw8QSU5myuo14PKMs4-iGY=",
    price: "25",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Oreo Milkshake ",
    image:
        "https://media.istockphoto.com/id/1151021565/photo/vanilla-creme-cookies-and-milkshake.jpg?s=612x612&w=is&k=20&c=WXKlABHesr_pB4V5-PnkJrmUwKako7RUPkNuoq1i4Y4=",
    price: "50",
    category: "Fresh & Chilled Beverages",
  ),
  FoodItem(
    name: "Veg Frankie ",
    image:
        "https://media.istockphoto.com/id/1024561344/photo/indian-veg-chapati-wrap-kathi-roll-served-in-a-plate-with-sauce-over-moody-background.jpg?s=612x612&w=is&k=20&c=gnJNxYJEn7sZ8-D1egsNRIzubBMVwjR9yHJ7PWfsMRQ=",
    price: "40",
    category: "Sandwiches & Wraps",
  ),
  FoodItem(
    name: "Schezwan Noodle Frankie ",
    image:
        "https://i.ytimg.com/vi/iwShr_uBUXM/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBtFNV2djiSPZB__gtNdqAKqqQ8xQ",
    price: "60",
    category: "Sandwiches & Wraps",
  ),
  FoodItem(
    name: "veg sandwich",
    image:
        "https://media.istockphoto.com/id/1328164559/photo/veg-grilled-sandwich.jpg?s=612x612&w=is&k=20&c=5zPWQrpz9xqn_zj20rmoikwlPFPikSLysqxHhbXbuew=",
    price: "40",
    category: "Sandwiches & Wraps",
  ),
  FoodItem(
    name: "cheese paneer sandwich",
    image:
        "https://media.istockphoto.com/id/1079003392/photo/cheese-toast.jpg?s=612x612&w=is&k=20&c=EcMn42S1cFlUwXKDj_2tpiPHdwne_QqlbDpVG0PX25k=",
    price: "60",
    category: "Sandwiches & Wraps",
  ),
  FoodItem(
    name: "Oreo Biscuit(50 g)",
    image:
        "https://media.istockphoto.com/id/458552725/photo/oreo-cookies.jpg?s=612x612&w=0&k=20&c=Fqx8l0f4alo7-OopsrSc_zKexteBTVSQvIuh1RrSyOM=",
    price: "10",
    category: "Packaged Foods",
  ),
  FoodItem(
    name: "Dairy Milk chocolate",
    image:
        "https://media.istockphoto.com/id/469741712/photo/bar-of-cadbury-dairy-milk-chocolate-2011.jpg?s=2048x2048&w=is&k=20&c=pa16Gfs7gHSyTj2vFdW6BN7gNUTa_fquQRoS8VZiX3o=",
    price: "10",
    category: "Packaged Foods",
  ),
  FoodItem(
    name: "Kitkat Chocolate",
    image:
        "https://gcp-na-images.contentstack.com/v3/assets/bltea6093859af6183b/blt0c4c5bafc55eda34/69cd51cbeca0375f556cfb54/KitKat-Stolen.jpg?branch=production&width=3840&quality=75&auto=webp&crop=3%3A2",
    price: "10",
    category: "Packaged Foods",
  ),
  FoodItem(
    name: "Goodday biscuits(50 g)",
    image:
        "https://bsmedia.business-standard.com/_media/bs/img/article/2015-08/25/full/1440518606-0653.jpg",
    price: "10",
    category: "Packaged Foods",
  ),
  FoodItem(
    name: "Lays(30 g)",
    image:
        "https://media.istockphoto.com/id/458987231/photo/potato-chips.jpg?s=612x612&w=is&k=20&c=8uPCyORZMeHM_vnx4y_RflRkLPH5vvGcuY4IfoVj9Ac=",
    price: "10",
    category: "Packaged Foods",
  ),
];
