import 'package:flutter/material.dart';

class AvailableDoctor {
  final String? name, sector, patients, image;
  final int? experience;

  AvailableDoctor(
      {this.name, this.sector, this.experience, this.patients, this.image});
}

List<AvailableDoctor> demoAvailableDoctors = [
  AvailableDoctor(
    name: "Dr. Serena Gome",
    sector: "Medicine Specialist",
    experience: 8,
    patients: '1.08K',
    image: "assets/images/Serena_Gome.png",
  ),
  AvailableDoctor(
    name: "Dr. Asma Khan",
    sector: "Medicine Specialist",
    experience: 5,
    patients: '2.7K',
    image: "assets/images/Asma_Khan.png",
  ),
  AvailableDoctor(
    name: "Dr. Kiran Shakia",
    sector: "Medicine Specialist",
    experience: 5,
    patients: '2.7K',
    image: "assets/images/Kiran_Shakia.png",
  ),
  AvailableDoctor(
    name: "Dr. Masuda Khan",
    sector: "Medicine Specialist",
    experience: 5,
    patients: '2.7K',
    image: "assets/images/Masuda_Khan.png",
  ),
  AvailableDoctor(
    name: "Dr. Johir Raihan",
    sector: "Medicine Specialist",
    experience: 5,
    patients: '2.7K',
    image: "assets/images/Johir_Raihan.png",
  ),
];

// Simple page to display available doctors. This was added so other pages
// (like ArticleDetail) can navigate to a consistent listing UI.
class AvailableDoctorPage extends StatelessWidget {
  const AvailableDoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Doctors'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: demoAvailableDoctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final d = demoAvailableDoctors[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      d.image != null ? AssetImage(d.image!) : null,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(d.sector ?? '',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('${d.experience ?? 0} yrs',
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(width: 12),
                          Text(d.patients ?? '',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder action: in a fuller UX this would start
                    // a booking flow or open the doctor's profile.
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Contacting ${d.name}...')));
                  },
                  child: const Text('Consult'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}