import 'package:flutter/material.dart';

class AccountPrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account Privacy & Terms",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB2E59C), // Light Green
                Color(0xFFFFF9C4), // Soft Yellow
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Privacy Policy"),
              _sectionText(
                "This privacy policy applies to the Agrive Mart app for mobile devices that was created by Agrive Mart as a Commercial service. This service is intended for use \"AS IS\".",
              ),
              _sectionTitle("Information Collection and Use"),
              _sectionText(
                  "The Application collects information when you download and use it. This information may include: \n\n"
                  "• Your device's Internet Protocol address (e.g., IP address)\n"
                  "• The pages of the Application that you visit, the time and date of your visit, the time spent on those pages\n"
                  "• The operating system you use on your mobile device\n"
                  "The Application collects your device's location, which helps the Service Provider determine your approximate geographical location and make use of it in the following ways:\n"
                  "1. Geolocation Services: The Service Provider utilizes location data to provide features such as personalized content, relevant recommendations, and location-based services.\n"
                  "2. Analytics and Improvements: Aggregated and anonymized location data helps the Service Provider to analyze user behavior, identify trends, and improve the overall performance and functionality of the Application.\n"
                  "3. Third-Party Services: Periodically, the Service Provider may transmit anonymized location data to external services. These services assist them in enhancing the Application and optimizing their offerings.\n"
                  "The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices, and marketing promotions."),
              _sectionTitle("Third-Party Access"),
              _sectionText(
                  "Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.\n"
                  "Please note that the Application utilizes third-party services that have their own Privacy Policy about handling data. Below are the links to the Privacy Policy of the third-party service providers used by the Application:\n"
                  "Google Play Services"),
              _sectionTitle("Terms and Conditions"),
              _sectionText("Last updated in January 2025"),
              _sectionTitle("Terms of Use"),
              _sectionText("Thank you for using Agrive Mart.\n"
                  "For abundant clarity, Agrive Mart and/or the trademark Agrive Mart are neither related, linked, nor interconnected in any manner or nature to any other business entities unless specifically mentioned.\n"
                  "The terms and conditions/terms of use (Terms) governing the Agrive Mart application (defined below) and the services (defined below) follow:\n"),
              _sectionTitle("Acceptance of Terms"),
              _sectionText(
                  "These Terms are intended to make you aware of your legal rights and responsibilities with respect to your access to and use of Agrive Mart’s mobile or software application (collectively referred to as the “Agrive Mart Application”), including but not limited to the services offered by Agrive Mart (Services).\n"
                  "Your use/access of the Agrive Mart Application shall be governed by these Terms and Agrive Mart’s Privacy Policy. By accessing the Agrive Mart Application and/or undertaking any purchase, you agree to be bound by these Terms and acknowledge that it constitutes an agreement between you and Agrive Mart.\n"
                  "If you do not accept the Terms or are unable to comply with them, you may not access the Agrive Mart Application or use its Services.These Terms may be updated from time to time by Agrive Mart without prior notice. It is recommended that you review these Terms regularly.For clarifications regarding the Terms, contact us at **prabirkumar1992@gmail.com**."),
              _sectionTitle("Services Overview"),
              _sectionText(
                "The Agrive Mart Application is a single-vendor platform that enables users to browse and purchase products directly from Agrive Mart. Agrive Mart manages and sells products/services directly to consumers and offers additional delivery services, where applicable.Agrive Mart reserves the right to modify or discontinue any part of the Services at any time without notice. Agrive Mart disclaims all warranties and liabilities associated with third-party links, if any, included on the platform.",
              ),
              _sectionTitle("Eligibility"),
              _sectionText(
                "Persons who are “incompetent to contract” under the Indian Contract Act, 1872, including minors, are not eligible to use the Agrive Mart Platform. Minors may only use the platform under the supervision of an adult parent or legal guardian.",
              ),
              _sectionTitle("Account & Registration Obligations"),
              _sectionText(
                  "All users must register and log in to place orders on the Agrive Mart Platform.\n"
                  "By registering, you agree to provide accurate and updated details for communication and order-related updates.\n"
                  "By registering your mobile number, you consent to receiving updates through calls, SMS, or emails."),
              _sectionTitle("Limited License & Access"),
              _sectionText(
                  "Agrive Mart grants you a personal, limited, non-transferable, and revocable license to access and use the platform for personal purposes only.\n"
                  "You agree not to reproduce, modify, or exploit the platform or its content for commercial use without Agrive Mart's prior written consent."),
              _sectionTitle("Prohibited Conduct"),
              _sectionText("You agree not to:\n"
                  "1. Post or share harmful, offensive, or illegal content.\n"
                  "2. Violate intellectual property rights.\n"
                  "3. Engage in activities that threaten the security or integrity of the platform.\n"
                  "Agrive Mart reserves the right to monitor, review, or remove any content that violates these terms or applicable laws."),
              _sectionTitle("Termination"),
              _sectionText(
                  "Agrive Mart reserves the right to terminate your access to the platform for violation of these terms or misuse of its services."),
              _sectionTitle("Desclaimers"),
              _sectionText(
                  "You acknowledge and undertake that you are accessing the Services on the Agrive Mart platform and transacting at your own risk while using your best judgment before making any purchases. Agrive Mart strives to display product information, including color, size, shape, and appearance, as accurately as possible. However, due to variations in device displays, the actual product color, size, shape, and appearance may differ slightly from their depiction on your mobile or computer screen.Agrive Mart makes no warranties, express or implied, regarding the accuracy, completeness, or reliability of the product descriptions or representations on the platform. Products and services are provided on an as is and as available basis, and Agrive Mart disclaims any liability for errors, inaccuracies, or omissions in the product information provided.You acknowledge and agree that Agrive Mart shall not be held responsible for any product's quality, merchantability, or fitness for a particular purpose, nor for delays or damages arising from circumstances such as product unavailability or technical errors. By purchasing through the Agrive Mart platform, you agree to adhere to these Terms and acknowledge that any issues related to a product must be resolved directly with Agrive Mart."),
              _sectionTitle("Delivery Failures and Liability"),
              _sectionText(
                  "If any delivery is delayed or returned due to incorrect delivery details, recipient unavailability, or refusal to accept the order at the time of delivery, Agrive Mart will not be held responsible for such incidents. Any costs incurred for re-delivery or order return due to these reasons will be borne by you.\n"),
              _sectionText(
                  "While Agrive Mart endeavors to deliver products within the estimated delivery period mentioned during the order placement, it does not guarantee or warrant delivery timelines, which may be subject to delays due to factors beyond reasonable control. These include, but are not limited to, demand fluctuations, traffic, weather conditions, force majeure events, or delivery-related challenges."),
              _sectionTitle("Responsibility for Delivered Products"),
              _sectionText(
                  "Orders will be delivered to the provided address when a person is available to receive them. If you request the delivery partner to leave the order at your doorstep or hand it over to another person, you accept full responsibility for the products. Agrive Mart shall not be liable for any theft, tampering, contamination, or damage caused due to the order being left unattended."),
              _sectionTitle("Cash on Delivery (COD) Orders"),
              _sectionText(
                  "For COD orders, you are solely responsible for ensuring that the exact payment is made at the time of delivery. Agrive Mart will not be liable for any discrepancies in the cash payment, including overpayment or underpayment."),
              _sectionTitle("Use of Services"),
              _sectionText(
                  "You agree to use the services provided by Agrive Mart for lawful purposes only and comply with all applicable laws and regulations. Any misuse of the platform or services may result in suspension or termination of your account."),
              _sectionTitle("Authenticity of Information"),
              _sectionText(
                  "You shall provide authentic and accurate information whenever requested. Agrive Mart reserves the right to verify the information provided by you at any time. If any information is found to be false or misleading, Agrive Mart reserves the right to cancel your registration, reject orders, and bar you from using its services without prior notice or liability."),
              _sectionTitle("Service Charges"),
              _sectionText(
                  "Orders placed through Agrive Mart may include delivery charges, handling charges, or other applicable fees, which will be disclosed during the checkout process. By placing the order, you agree to pay the applicable charges. Agrive Mart may also provide promotional offers, discounts, or credits at its discretion, which can be modified or discontinued without notice."),
              _sectionTitle("Product Descriptions"),
              _sectionText(
                  "You acknowledge that you have reviewed the product descriptions carefully before placing an order. By proceeding with a purchase, you agree to the terms outlined in the product description."),
              _sectionTitle("Content Disclaimer"),
              _sectionText(
                  "While using Agrive Mart, you may encounter content that could be deemed offensive or objectionable by some. You agree to use the platform and services at your own discretion and risk. Agrive Mart disclaims any liability arising from such content."),
              _sectionTitle("Platform Updates"),
              _sectionText(
                  "To ensure the best user experience, Agrive Mart may periodically update or upgrade its application and services. You may be required to install updates to continue using the platform. These updates aim to enhance platform functionality, security, and reliability."),
              _sectionTitle("Continuous Improvement"),
              _sectionText(
                  "Agrive Mart is committed to improving its platform and services. From time to time, research and experiments may be conducted to refine features, improve usability, and enhance customer satisfaction. As a result, some features may vary among users at any given time."),
              _sectionTitle("Taxes on Your Order"),
              _sectionText(
                  "In respect of orders placed through Agrive Mart, we will issue relevant documents, including order summaries and tax invoices, as mandated by applicable laws and common business practices. Your order may consist of the following components along with their corresponding documentation:\n"
                  "Supply of Goods by Agrive Mart: A Tax Invoice cum Bill of Supply will be issued by Agrive Mart for all goods supplied.\n"
                  "Supply of Services by Agrive Mart: A Tax Invoice will be issued by Agrive Mart for any applicable services provided.\n"
                  "The aforementioned documents will be available on the order summary page once the goods or services have been delivered to you.\n"
                  "You acknowledge and agree that any entitlement to GST benefits related to goods or services purchased through Agrive Mart will be subject to the applicable GST terms and conditions. This includes providing a valid GST number, as required at the time of order placement. The GST terms and conditions shall be deemed incorporated into this policy by reference and may be updated periodically."),
              _sectionTitle("Order Cancellation Policy"),
              _sectionText(
                  "Cancellation by User: You acknowledge that any cancellation, or attempted or purported cancellation, of an order (a) that does not comply with these terms or (b) is due to reasons not attributable to Agrive Mart, will be considered a breach of these Terms. Any cancellation request is subject to acceptance by Agrive Mart. In cases where cancellations are permitted, we will initiate a refund, which may be in the form of promotional codes or coupons, subject to the terms and conditions applicable to such offers, including any validity period.\n"
                  "Cancellation by Agrive Mart: Agrive Mart may cancel an order in the following situations:\n"
                  "(a) If there is suspicion of fraudulent activity associated with the transaction.\n"
                  "(b) If the transaction violates any of the Terms.\n"
                  "(c) If the product(s) ordered are unavailable.\n"
                  "(d) Due to any delivery-related logistical difficulties outside Agrive Mart's control.\n"
                  "In such cases, Agrive Mart will initiate a refund, if applicable, within approximately 72 hours of the cancellation. The refund may be issued in the form of credit, cashback, coupon, or promotional codes, subject to the applicable terms, including any validity period.\n"
                  "Pricing and Product Information Accuracy: Agrive Mart strives to ensure the accuracy of product specifications and pricing. However, due to technical issues, typographical errors, or incorrect product information provided by third-party sellers, there may be instances where the specifications or prices are inaccurate. In such cases, you will be notified, and Agrive Mart reserves the right to cancel the order and issue a refund, if applicable, in the form of credit, cashback, coupon, or promotional codes, subject to the applicable terms and validity period.\n"
                  "Right to Deny Access: Agrive Mart reserves the right to deny access to users who fail to comply with these Terms or who are suspected of engaging in fraudulent activity. Additionally, we reserve the right to cancel any future orders placed by such users.\n"),
              _sectionTitle("Returns & Refunds Policy"),
              _sectionText(
                  "Non-Returnable Products: Once delivered, products are non-returnable, non-replaceable, and non-exchangeable.\n\n"
                  "Refund Processing: Refunds will be processed within 7 working days from the approval date."
                  "Refund Method:Refunds will be made to the same bank account or payment method from which the original payment was made."),
              _sectionTitle("Contact Us"),
              _sectionText(
                "If you have any questions regarding the Privacy Policy or Terms and Conditions, please contact us at **prabirkumar1992@gmail.com**.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
