class Slide {
  String title;
  String description;
  String image;

  Slide({required this.title, required this.description, required this.image});
}

final slideList = [
  Slide(
      title: "Sports Management",
      description: "Now you manage all sport fields across the world.",
      image: "onboarding/animation1.json"),
  Slide(
      title: "Track Ananlysis",
      description: "Track Ananlysis about all bookings and sport users.",
      image: "onboarding/animation2.json"),

  Slide(
      title: "Get Bookings",
      description:
      "You can get bookings & can start earnings.",
      image: "onboarding/animation3.json"),

];