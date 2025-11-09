import 'package:flutter/material.dart';
import '../theme/colors.dart';

class FirstAidChatbotPage extends StatefulWidget {
  const FirstAidChatbotPage({super.key});

  @override
  State<FirstAidChatbotPage> createState() => _FirstAidChatbotPageState();
}

class _FirstAidChatbotPageState extends State<FirstAidChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  // Local knowledge base for first aid
  final Map<String, String> _firstAidDatabase = {
    'burn': 'For burns: Cool the burn with running cold water for 10-20 minutes. Do not apply ice. Cover with a clean bandage. Seek medical help for severe burns.',
    'burns': 'For burns: Cool the burn with running cold water for 10-20 minutes. Do not apply ice. Cover with a clean bandage. Seek medical help for severe burns.',
    'bruise': 'For bruises: Apply ice wrapped in a cloth for 15-20 minutes. Elevate the injured area. Rest and avoid pressure on the area.',
    'bruises': 'For bruises: Apply ice wrapped in a cloth for 15-20 minutes. Elevate the injured area. Rest and avoid pressure on the area.',
    'cut': 'For cuts: Wash with soap and water. Apply pressure with a clean cloth to stop bleeding. Cover with a bandage. Seek medical help if deep or won\'t stop bleeding.',
    'cuts': 'For cuts: Wash with soap and water. Apply pressure with a clean cloth to stop bleeding. Cover with a bandage. Seek medical help if deep or won\'t stop bleeding.',
    'sprain': 'For sprains: Rest, Ice, Compression, Elevation (RICE). Apply ice for 15-20 minutes. Compress with an elastic bandage. Elevate the injured area.',
    'sprains': 'For sprains: Rest, Ice, Compression, Elevation (RICE). Apply ice for 15-20 minutes. Compress with an elastic bandage. Elevate the injured area.',
    'fracture': 'For suspected fractures: Immobilize the injured area. Apply ice if possible. Do not try to straighten broken bones. Seek immediate medical help.',
    'broken bone': 'For suspected fractures: Immobilize the injured area. Apply ice if possible. Do not try to straighten broken bones. Seek immediate medical help.',
    'choking': 'For choking: If person can cough, encourage them to continue. If they cannot breathe, perform Heimlich maneuver. Call emergency services immediately.',
    'heart attack': 'For heart attack: Call emergency services immediately. Help person sit or lie down. If available, give aspirin if not allergic. Start CPR if unconscious.',
    'stroke': 'For stroke: Call emergency services immediately. Note the time symptoms started. Help person lie down with head slightly elevated. Do not give food or drink.',
    'fever': 'For fever: Rest and drink plenty of fluids. Take fever-reducing medication like acetaminophen. Seek medical help if fever is very high or persistent.',
    'headache': 'For headaches: Rest in a quiet, dark room. Apply cold or warm compress. Stay hydrated. Over-the-counter pain relievers may help.',
    'nosebleed': 'For nosebleeds: Sit up and lean forward. Pinch the soft part of nose for 10 minutes. Apply cold compress. Seek medical help if bleeding won\'t stop.',
    'poisoning': 'For poisoning: Call poison control immediately. Do not induce vomiting unless instructed. Save the container. Seek immediate medical help.',
    'allergic reaction': 'For allergic reactions: If severe (difficulty breathing, swelling), call emergency services. Use epinephrine if available. Remove allergen if possible.',
    'heat stroke': 'For heat stroke: Move to cool area immediately. Remove excess clothing. Cool with water and fan. Seek immediate medical help.',
    'hypothermia': 'For hypothermia: Move to warm area. Remove wet clothing. Warm gradually with blankets. Give warm fluids if conscious. Seek medical help.',
    'drowning': 'For drowning: Call emergency services. Start CPR if trained. Continue until help arrives or person starts breathing.',
    'seizure': 'For seizures: Protect from injury. Do not restrain. Clear area of hard objects. Time the seizure. Call emergency services if first seizure or prolonged.',
    'diabetes': 'For diabetic emergency: If low blood sugar, give sugar (juice, candy). If high blood sugar, seek medical help. Always carry medical ID.',
    'asthma': 'For asthma attack: Use inhaler if available. Sit up and try to stay calm. Seek immediate medical help if symptoms worsen.',
    'bleeding': 'For severe bleeding: Apply direct pressure with clean cloth. Elevate injured area. Apply pressure to pressure points if needed. Seek immediate help.',
    'shock': 'For shock: Lay person down with legs elevated. Keep warm. Do not give food or drink. Seek immediate medical help.',
    'eye injury': 'For eye injuries: Do not rub eye. Flush with clean water for chemical exposure. Cover both eyes and seek immediate medical help.',
    'bee sting': 'For bee stings: Remove stinger if visible. Wash area. Apply cold compress. Seek medical help if allergic reaction occurs.',
    'snake bite': 'For snake bites: Keep calm and still. Call emergency services. Note snake appearance if safe. Do not cut or suck wound.',
    'frostbite': 'For frostbite: Move to warm area. Do not rub affected area. Warm gradually with warm water. Seek immediate medical help.',
    'sunburn': 'For sunburn: Cool with cold water. Apply moisturizer. Stay out of sun. Seek medical help for severe burns.',
    'dehydration': 'For dehydration: Drink water or electrolyte solution. Rest in cool area. Seek medical help if severe symptoms.',
    'food poisoning': 'For food poisoning: Stay hydrated. Rest. Seek medical help if severe vomiting, diarrhea, or high fever.',
    'migraine': 'For migraines: Rest in dark, quiet room. Apply cold compress. Take prescribed medication. Avoid triggers.',
    'back pain': 'For back pain: Rest but avoid prolonged bed rest. Apply ice then heat. Use proper posture. Seek medical help if severe.',
    'toothache': 'For toothache: Rinse with warm salt water. Use over-the-counter pain relievers. See dentist promptly.',
    'earache': 'For earache: Use warm compress. Over-the-counter pain relievers. See doctor if pain persists or fever present.',
    'sore throat': 'For sore throat: Gargle with salt water. Stay hydrated. Use throat lozenges. See doctor if severe or persistent.',
    'cough': 'For cough: Stay hydrated. Use cough syrup if needed. See doctor if cough persists over 2 weeks or has blood.',
    'cold': 'For common cold: Rest and stay hydrated. Use over-the-counter medications for symptoms. See doctor if symptoms worsen.',
    'flu': 'For flu: Rest and stay hydrated. Use fever reducers. Seek medical help if difficulty breathing or high fever.',
    'stomach pain': 'For stomach pain: Rest and avoid heavy foods. Use heating pad. Seek medical help if severe or persistent.',
    'nausea': 'For nausea: Sip clear fluids. Eat bland foods. Avoid strong odors. Seek medical help if persistent vomiting.',
    'constipation': 'For constipation: Increase fiber and water intake. Exercise regularly. Use over-the-counter laxatives if needed.',
    'diarrhea': 'For diarrhea: Stay hydrated with electrolyte solutions. Eat bland foods. Seek medical help if bloody or persistent.',
    'rash': 'For rashes: Keep area clean and dry. Use over-the-counter creams. Seek medical help if spreading or with fever.',
    'itchy skin': 'For itchy skin: Avoid scratching. Use moisturizers. Take cool baths. Seek medical help if severe.',
    'insect bite': 'For insect bites: Clean area. Apply cold compress. Use antihistamine cream. Seek help if allergic reaction.',
    'wound': 'For wounds: Clean with soap and water. Apply antibiotic ointment. Cover with bandage. Watch for infection signs.',
    'infection': 'For infections: Keep area clean. Apply warm compress. Use antibiotics if prescribed. Seek medical help.',
    'swelling': 'For swelling: Elevate affected area. Apply cold compress. Rest. Seek medical help if severe.',
    'pain': 'For pain: Rest affected area. Apply ice or heat. Use over-the-counter pain relievers. Seek medical help if severe.',
    'fatigue': 'For fatigue: Rest adequately. Stay hydrated. Eat balanced meals. Seek medical help if persistent.',
    'dizziness': 'For dizziness: Sit or lie down. Stay hydrated. Avoid sudden movements. Seek medical help if persistent.',
    'shortness of breath': 'For shortness of breath: Sit up and stay calm. Use prescribed inhalers. Seek immediate medical help.',
    'chest pain': 'For chest pain: Call emergency services immediately. Sit up and stay calm. Chew aspirin if not allergic.',
    'abdominal pain': 'For abdominal pain: Rest and avoid heavy foods. Apply warm compress. Seek medical help if severe.',
    'joint pain': 'For joint pain: Rest affected joint. Apply ice or heat. Use over-the-counter pain relievers.',
    'muscle pain': 'For muscle pain: Rest affected muscle. Apply ice then heat. Gentle stretching may help.',
    'neck pain': 'For neck pain: Use proper posture. Apply ice or heat. Gentle neck exercises. Seek medical help if severe.',
    'shoulder pain': 'For shoulder pain: Rest arm. Apply ice. Use sling if needed. Seek medical help for severe pain.',
    'knee pain': 'For knee pain: Rest and elevate. Apply ice. Use knee brace if available. Seek medical help.',
    'ankle pain': 'For ankle pain: Rest, ice, compression, elevation. Avoid weight bearing. Seek medical help.',
    'wrist pain': 'For wrist pain: Rest and immobilize. Apply ice. Use wrist brace. Seek medical help.',
    'finger pain': 'For finger pain: Rest and elevate. Apply ice. Buddy tape if needed. Seek medical help.',
    'toe pain': 'For toe pain: Rest and elevate. Apply ice. Wear comfortable shoes. Seek medical help.',
    'head injury': 'For head injuries: Seek immediate medical help. Do not leave alone. Watch for concussion symptoms.',
    'concussion': 'For concussion: Rest brain and body. Avoid activities that worsen symptoms. Seek medical evaluation.',
    'black eye': 'For black eye: Apply cold compress. Rest. Seek medical help if vision affected.',
    'splinter': 'For splinters: Clean area. Use sterilized needle to remove. Apply antibiotic ointment.',
    'blister': 'For blisters: Keep intact if possible. Clean and cover. Seek medical help if infected.',
    'corn': 'For corns: Wear proper footwear. Use corn pads. Seek podiatrist help if persistent.',
    'callus': 'For calluses: Soak and gently file. Use moisturizer. Wear proper shoes.',
    'ingrown toenail': 'For ingrown toenail: Soak foot in warm water. Gently lift nail edge. Seek podiatrist help.',
    'plantar fasciitis': 'For plantar fasciitis: Rest foot. Ice and stretch. Wear supportive shoes. Seek medical help.',
    'shin splints': 'For shin splints: Rest and ice. Stretch calves. Wear proper shoes. Seek medical help.',
    'stress fracture': 'For stress fractures: Rest completely. Use crutches if needed. Seek orthopedic evaluation.',
    'tennis elbow': 'For tennis elbow: Rest arm. Apply ice. Use elbow brace. Seek physical therapy.',
    'carpal tunnel': 'For carpal tunnel: Rest wrist. Use wrist splint. Seek medical evaluation.',
    'rotator cuff': 'For rotator cuff injury: Rest arm. Apply ice. Seek orthopedic evaluation.',
    'meniscus tear': 'For meniscus tear: Rest and elevate. Apply ice. Use crutches. Seek orthopedic evaluation.',
    'acl tear': 'For ACL tear: Stop activity immediately. Apply ice and compression. Seek orthopedic evaluation.',
    'mcl tear': 'For MCL tear: Rest and protect knee. Apply ice. Use knee brace. Seek medical evaluation.',
    'achilles tendon': 'For Achilles tendon injury: Rest and elevate. Apply ice. Seek medical evaluation.',
    'hamstring strain': 'For hamstring strain: Rest, ice, compression. Gentle stretching later. Seek medical help.',
    'quadriceps strain': 'For quadriceps strain: Rest and elevate. Apply ice. Gentle strengthening later.',
    'calf strain': 'For calf strain: Rest, ice, compression, elevation. Gentle stretching later.',
    'groin strain': 'For groin strain: Rest and protect area. Apply ice. Gentle stretching later.',
    'hip pain': 'For hip pain: Rest and avoid aggravating activities. Apply ice. Seek medical evaluation.',
    'sciatica': 'For sciatica: Rest and avoid bending. Apply ice/heat. Gentle stretching. Seek medical help.',
    'herniated disc': 'For herniated disc: Rest and avoid heavy lifting. Apply ice. Seek medical evaluation.',
    'arthritis': 'For arthritis flare: Rest affected joint. Apply ice or heat. Use prescribed medications.',
    'gout': 'For gout attack: Rest and elevate. Apply ice. Take prescribed medications. Stay hydrated.',
    'fibromyalgia': 'For fibromyalgia flare: Rest and pacing activities. Apply heat. Use prescribed treatments.',
    'chronic fatigue': 'For chronic fatigue: Balance rest and activity. Stay hydrated. Follow treatment plan.',
    'sleep disorder': 'For sleep issues: Maintain regular schedule. Create good sleep environment. Seek medical help.',
    'anxiety': 'For anxiety: Practice deep breathing. Use relaxation techniques. Seek professional help if needed.',
    'depression': 'For depression: Stay connected with others. Exercise regularly. Seek professional help.',
    'panic attack': 'For panic attack: Breathe deeply and slowly. Ground yourself. Seek medical help if frequent.',
    'phobia': 'For phobias: Practice gradual exposure. Use relaxation techniques. Seek therapy help.',
    'ptsd': 'For PTSD symptoms: Practice grounding techniques. Seek trauma-informed therapy.',
    'ocd': 'For OCD symptoms: Practice exposure therapy. Use mindfulness. Seek professional help.',
    'bipolar': 'For mood episodes: Follow treatment plan. Monitor symptoms. Contact healthcare provider.',
    'schizophrenia': 'For psychotic symptoms: Take prescribed medications. Contact mental health crisis services.',
    'eating disorder': 'For eating disorder symptoms: Seek immediate professional help. Contact crisis hotline.',
    'substance abuse': 'For substance use crisis: Call addiction helpline. Seek immediate professional help.',
    'suicide': 'If suicidal thoughts: Call emergency services or crisis hotline immediately. You are not alone.',
    'self harm': 'For self-harm urges: Use coping strategies. Call crisis hotline. Seek immediate help.',
    'domestic violence': 'For domestic violence: Call emergency services. Go to safe location. Contact support services.',
    'sexual assault': 'For sexual assault: Call emergency services. Preserve evidence. Seek medical and counseling help.',
    'elder abuse': 'For elder abuse: Call adult protective services. Ensure safety. Seek legal help.',
    'child abuse': 'For child abuse: Call child protective services immediately. Ensure child safety.',
    'animal bite': 'For animal bites: Clean wound thoroughly. Seek medical help for rabies risk assessment.',
    'dog bite': 'For dog bites: Control bleeding. Clean with soap and water. Seek medical evaluation.',
    'cat bite': 'For cat bites: Clean thoroughly. Seek medical help due to infection risk.',
    'human bite': 'For human bites: Clean thoroughly. Seek medical help due to infection risk.',
    'marine animal': 'For marine animal stings: Rinse with vinegar for jellyfish. Seek medical help.',
    'jellyfish': 'For jellyfish stings: Rinse with vinegar. Remove tentacles. Seek medical help.',
    'shark bite': 'For shark bites: Control bleeding. Clean wound. Seek immediate medical help.',
    'lightning': 'For lightning strike: Call emergency services. Start CPR if needed. Monitor for complications.',
    'electrocution': 'For electric shock: Disconnect power source. Call emergency services. Start CPR if needed.',
    'chemical burn': 'For chemical burns: Flush with water for 20 minutes. Remove contaminated clothing. Seek immediate help.',
    'radiation': 'For radiation exposure: Remove contaminated clothing. Wash thoroughly. Seek medical help.',
    'altitude sickness': 'For altitude sickness: Descend immediately. Rest and hydrate. Seek medical help.',
    'motion sickness': 'For motion sickness: Look at horizon. Fresh air. Use acupressure bands.',
    'jet lag': 'For jet lag: Adjust sleep schedule gradually. Stay hydrated. Use melatonin if needed.',
    'travel sickness': 'For travel sickness: Sit by window. Avoid reading. Use ginger or acupressure.',
    'hangover': 'For hangover: Hydrate with electrolytes. Eat bland food. Rest. Avoid alcohol.',
    'overdose': 'For drug overdose: Call emergency services immediately. Provide information about substance.',
    'withdrawal': 'For withdrawal symptoms: Seek medical supervision. Follow detox plan. Get support.',
    'mental health': 'For mental health crisis: Call crisis hotline. Seek immediate professional help.',
    'emergency': 'For any emergency: Call emergency services immediately. Stay calm. Provide clear information.',
    'help': 'I can help with first aid information. Describe your situation or ask about specific injuries/illnesses.',
    'hello': 'Hello! I\'m your first aid assistant. How can I help you today?',
    'hi': 'Hi there! I\'m here to help with first aid information. What do you need?',
    'what': 'I can provide first aid information for various injuries and illnesses. Just describe your situation!',
    'how': 'Ask me about any injury or medical emergency, and I\'ll provide appropriate first aid guidance.',
  };

  @override
  void initState() {
    super.initState();
    _addBotMessage('Hello! I\'m your first aid assistant. I can help with information about injuries, illnesses, and emergency situations. What would you like to know?');
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _findBestMatch(String userMessage) {
    final message = userMessage.toLowerCase().trim();

    // Direct keyword matching
    for (final entry in _firstAidDatabase.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }

    // Check for partial matches
    final words = message.split(' ');
    for (final word in words) {
      if (word.length > 2) { // Ignore very short words
        for (final entry in _firstAidDatabase.entries) {
          if (entry.key.contains(word) || word.contains(entry.key)) {
            return entry.value;
          }
        }
      }
    }

    // Default responses
    if (message.contains('help') || message.contains('what')) {
      return 'I can provide first aid information for various situations. Try asking about specific injuries like "burn", "cut", "sprain", or illnesses like "fever", "headache".';
    }

    return 'I\'m sorry, I don\'t have specific information about that. Please describe the injury or illness more specifically, or ask about common emergencies like burns, cuts, sprains, or heart attacks.';
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _addUserMessage(text);
    _messageController.clear();

    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _findBestMatch(text);
      _addBotMessage(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Assistant'),
        backgroundColor: AppColors.lightGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'About',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Describe your situation...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => _handleSubmitted(_messageController.text),
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About First Aid Assistant'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This is an offline first aid assistant that provides immediate guidance for common injuries and emergencies.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                'Important Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• This is not a substitute for professional medical advice\n'
                '• Always call emergency services (112) for serious situations\n'
                '• Seek immediate medical help for severe injuries\n'
                '• Information is for educational purposes only',
                style: TextStyle(height: 1.5, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.lightGreen : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isUser ? Colors.white.withOpacity(0.7) : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}