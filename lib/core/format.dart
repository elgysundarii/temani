const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
