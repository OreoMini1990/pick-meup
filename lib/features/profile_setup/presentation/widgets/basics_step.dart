import 'package:flutter/material.dart';

class BasicsStep extends StatefulWidget {
  final int? age;
  final String job;
  final String regionCity;
  final String regionDistrict;
  final String bio;
  final Function(int?) onAgeChanged;
  final Function(String) onJobChanged;
  final Function(String, String) onRegionChanged;
  final Function(String) onBioChanged;

  const BasicsStep({
    super.key,
    required this.age,
    required this.job,
    required this.regionCity,
    required this.regionDistrict,
    required this.bio,
    required this.onAgeChanged,
    required this.onJobChanged,
    required this.onRegionChanged,
    required this.onBioChanged,
  });

  @override
  State<BasicsStep> createState() => _BasicsStepState();
}

class _BasicsStepState extends State<BasicsStep> {
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  String _selectedCity = '';
  String _selectedDistrict = '';

  final Map<String, List<String>> _regions = {
    'Seoul': ['Gangnam', 'Gangdong', 'Gangbuk', 'Gangseo', 'Gwanak', 'Gwangjin', 'Guro', 'Geumcheon', 'Nowon', 'Dobong', 'Dongdaemun', 'Dongjak', 'Mapo', 'Seodaemun', 'Seocho', 'Seongdong', 'Seongbuk', 'Songpa', 'Yangcheon', 'Yeongdeungpo', 'Yongsan', 'Jongno', 'Jung', 'Jungnang'],
    'Gyeonggi': ['Suwon', 'Seongnam', 'Goyang', 'Yongin', 'Bucheon', 'Ansan', 'Anyang', 'Namyangju', 'Hwaseong', 'Pyeongtaek', 'Siheung', 'Gimpo', 'Gwangju', 'Icheon', 'Yangju', 'Uijeongbu', 'Hanam', 'Osan', 'Gwangmyeong', 'Paju', 'Gunpo', 'Guri', 'Yeoju', 'Dongducheon', 'Anseong', 'Uiwang', 'Gwacheon', 'Yangpyeong', 'Yeoncheon', 'Pocheon', 'Gapyeong'],
    'Incheon': ['Jung', 'Dong', 'Michuhol', 'Yeonsu', 'Namdong', 'Bupyeong', 'Gyeyang', 'Seo', 'Ganghwa', 'Ongjin'],
    'Busan': ['Haeundae', 'Saha', 'Geumjeong', 'Gangseo', 'Gangdong', 'Dong', 'Dongnae', 'Busanjin', 'Buk', 'Sasang', 'Saha', 'Saha', 'Saha', 'Saha', 'Saha', 'Saha', 'Saha', 'Saha', 'Saha', 'Saha'],
    'Daegu': ['Jung', 'Dong', 'Seo', 'Nam', 'Buk', 'Suseong', 'Dalseo', 'Dalseong', 'Gunwi'],
    'Gwangju': ['Dong', 'Seo', 'Nam', 'Buk', 'Gwangsan'],
    'Daejeon': ['Jung', 'Dong', 'Seo', 'Yuseong', 'Daedeok'],
    'Ulsan': ['Jung', 'Nam', 'Dong', 'Buk', 'Ulju'],
  };

  @override
  void initState() {
    super.initState();
    _jobController.text = widget.job;
    _bioController.text = widget.bio;
    _selectedCity = widget.regionCity;
    _selectedDistrict = widget.regionDistrict;
  }

  @override
  void dispose() {
    _jobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Age
                  TextFormField(
                    initialValue: widget.age?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Age *',
                      hintText: 'Enter your age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final age = int.tryParse(value);
                      widget.onAgeChanged(age);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Job
                  TextFormField(
                    controller: _jobController,
                    decoration: const InputDecoration(
                      labelText: 'Job *',
                      hintText: 'Enter your job',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: widget.onJobChanged,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Region
                  DropdownButtonFormField<String>(
                    value: _selectedCity.isNotEmpty ? _selectedCity : null,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      border: OutlineInputBorder(),
                    ),
                    items: _regions.keys.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (city) {
                      setState(() {
                        _selectedCity = city ?? '';
                        _selectedDistrict = '';
                      });
                      widget.onRegionChanged(_selectedCity, _selectedDistrict);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // District
                  if (_selectedCity.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict.isNotEmpty ? _selectedDistrict : null,
                      decoration: const InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(),
                      ),
                      items: _regions[_selectedCity]?.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList() ?? [],
                      onChanged: (district) {
                        setState(() {
                          _selectedDistrict = district ?? '';
                        });
                        widget.onRegionChanged(_selectedCity, _selectedDistrict);
                      },
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Bio
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself (max 200 characters)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    onChanged: widget.onBioChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
