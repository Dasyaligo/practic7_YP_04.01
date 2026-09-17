class PhoneQuery {
  final String search;
  final int? brandId;
  final double? priceFrom;
  final double? priceTo;
  final int? storage;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const PhoneQuery({
    this.search = '',
    this.brandId,
    this.priceFrom,
    this.priceTo,
    this.storage,
    this.sortField = 'model',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  PhoneQuery copyWith({
    String? search,
    Object? brandId = _unset,
    Object? priceFrom = _unset,
    Object? priceTo = _unset,
    Object? storage = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return PhoneQuery(
      search: search ?? this.search,
      brandId: brandId == _unset ? this.brandId : brandId as int?,
      priceFrom: priceFrom == _unset ? this.priceFrom : priceFrom as double?,
      priceTo: priceTo == _unset ? this.priceTo : priceTo as double?,
      storage: storage == _unset ? this.storage : storage as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();
}