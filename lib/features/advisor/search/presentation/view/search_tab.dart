class SearchTab {
  final String id;
  final String title;
  const SearchTab({required this.id, required this.title});
}

const kSearchTabs = [
  SearchTab(id: 'all', title: 'all'),
  SearchTab(id: 'advisors', title: 'advisors'),
  SearchTab(id: 'users', title: 'users'),
  SearchTab(id: 'posts', title: 'posts'),
  SearchTab(id: 'events', title: 'events'),
];
