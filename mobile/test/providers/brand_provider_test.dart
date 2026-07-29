import 'package:flutter_test/flutter_test.dart';
import 'package:beyondc/data/models/brand_models.dart';
import 'package:beyondc/providers/brand_provider.dart';

void main() {
  group('CreatorDiscoveryFilters', () {
    test('default values are correct', () {
      const filters = CreatorDiscoveryFilters();
      expect(filters.niche, isNull);
      expect(filters.tier, isNull);
      expect(filters.minFollowers, isNull);
      expect(filters.maxPrice, isNull);
    });

    test('copyWith updates single field', () {
      const filters = CreatorDiscoveryFilters();
      final updated = filters.copyWith(niche: 'tech');
      expect(updated.niche, 'tech');
      expect(updated.tier, isNull);
    });
  });

  group('CreatorDiscoveryState', () {
    test('copyWith updates fields', () {
      const state = CreatorDiscoveryState(
        creators: [],
        page: 1,
        hasMore: true,
        filters: CreatorDiscoveryFilters(),
      );

      final updated = state.copyWith(page: 3, hasMore: false);
      expect(updated.page, 3);
      expect(updated.hasMore, false);
    });
  });

  group('BrandState', () {
    test('initial state has correct defaults', () {
      const state = BrandState();
      expect(state.brandProfile, isNull);
      expect(state.creators, isEmpty);
      expect(state.campaigns, isEmpty);
      expect(state.creditBalance, 0);
      expect(state.isLoading, false);
      expect(state.activeFilter, 'All');
    });

    test('activeCampaignCount filters active campaigns', () {
      const state = BrandState(
        campaigns: [
          Campaign(id: '1', status: CampaignStatus.active),
          Campaign(id: '2', status: CampaignStatus.active),
          Campaign(id: '3', status: CampaignStatus.completed),
        ],
      );

      expect(state.activeCampaignCount, 2);
    });

    test('filteredCreators returns all when filter is All', () {
      const state = BrandState(
        creators: [
          CreatorDiscovery(id: '1', firstName: 'Alice', niches: ['fashion']),
          CreatorDiscovery(id: '2', firstName: 'Bob', niches: ['tech']),
        ],
      );

      expect(state.filteredCreators.length, 2);
    });

    test('filteredCreators filters by niche', () {
      const state = BrandState(
        creators: [
          CreatorDiscovery(id: '1', firstName: 'Alice', niches: ['fashion']),
          CreatorDiscovery(id: '2', firstName: 'Bob', niches: ['tech']),
        ],
        activeFilter: 'fashion',
      );

      expect(state.filteredCreators.length, 1);
      expect(state.filteredCreators.first.firstName, 'Alice');
    });

    test('upcomingEvents filters and sorts correctly', () {
      final now = DateTime.now();
      final future1 = now.add(const Duration(days: 10));
      final future2 = now.add(const Duration(days: 5));
      final past = now.subtract(const Duration(days: 1));

      final state = BrandState(
        events: [
          BrandEvent(id: '1', title: 'Future 1', eventDate: future1),
          BrandEvent(id: '2', title: 'Future 2', eventDate: future2),
          BrandEvent(
            id: '3',
            title: 'Past',
            eventDate: past,
            status: BrandEventStatus.completed,
          ),
        ],
      );

      expect(state.upcomingEvents.length, 2);
      expect(state.upcomingEvents.first.title, 'Future 2'); // closest first
    });

    test('pastEvents returns completed and past events', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 1));
      final future = now.add(const Duration(days: 10));

      final state = BrandState(
        events: [
          BrandEvent(id: '1', title: 'Past', eventDate: past),
          BrandEvent(id: '2', title: 'Future', eventDate: future),
        ],
      );

      expect(state.pastEvents.length, 1);
      expect(state.pastEvents.first.title, 'Past');
    });

    test('copyWith preserves fields', () {
      const state = BrandState();
      final updated = state.copyWith(
        creditBalance: 15,
        isLoading: true,
      );

      expect(updated.creditBalance, 15);
      expect(updated.isLoading, true);
      expect(updated.creators, isEmpty);
      expect(updated.campaigns, isEmpty);
    });
  });
}
