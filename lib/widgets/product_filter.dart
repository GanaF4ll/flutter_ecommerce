import 'package:flutter/material.dart';

class ProductFilter extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const ProductFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<ProductFilter> createState() => _ProductFilterState();
}

class _ProductFilterState extends State<ProductFilter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () => widget.onCategoryChanged(null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCategory == null
                      ? Colors.cyan[700]
                      : Colors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Tous', style: TextStyle(fontSize: 9)),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () => widget.onCategoryChanged('electronique'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCategory == 'electronique'
                      ? Colors.orange[700]
                      : Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Electronique',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () => widget.onCategoryChanged('vetements'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCategory == 'vetements'
                      ? Colors.blue[700]
                      : Colors.blue[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Vêtements', style: TextStyle(fontSize: 9)),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () => widget.onCategoryChanged('maison-cuisine'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCategory == 'maison-cuisine'
                      ? Colors.deepOrange[300]
                      : Colors.deepOrange[100],
                  foregroundColor: widget.selectedCategory == 'maison-cuisine'
                      ? Colors.white
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Maison', style: TextStyle(fontSize: 9)),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () => widget.onCategoryChanged('sports-loisirs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCategory == 'sports-loisirs'
                      ? Colors.red[700]
                      : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sports', style: TextStyle(fontSize: 9)),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 100,
              height: 30,
              child: ElevatedButton(
                onPressed: () => widget.onCategoryChanged('beaute-sante'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedCategory == 'beaute-sante'
                      ? Colors.green[700]
                      : Colors.green[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Santé', style: TextStyle(fontSize: 9)),
              ),
            ),
          ],
        ),
      ),
    );
    // return DropdownButton<String>(
    //   items: [
    //     DropdownMenuItem<String>(
    //       value: 'electronique',
    //       child: Text('Électronique'),
    //     ),
    //     DropdownMenuItem<String>(value: 'vetements', child: Text('Vêtements')),
    //     DropdownMenuItem<String>(
    //       value: 'maison-cuisine',
    //       child: Text('Maison & Cuisine'),
    //     ),
    //     DropdownMenuItem<String>(
    //       value: 'sports-loisirs',
    //       child: Text('Sports & Loisirs'),
    //     ),
    //     DropdownMenuItem<String>(
    //       value: 'beaute-sante',
    //       child: Text('Beauté & Santé'),
    //     ),
    //   ],
    //   value: selectedCategory,
    //   onChanged: (String? value) {
    //     setState(() {
    //       selectedCategory = value;
    //     });
    //   },
    // );
  }
}
