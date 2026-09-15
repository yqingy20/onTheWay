# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Stack

Native SwiftUI application in the existing Xcode project. The project targets iPhone and iPad.

## Users

- Requesters need a small, immediate, local errand completed without paying for a dedicated trip.
- Helpers want to turn spare time, their current position, and an already-planned route into earnings.
- One account can use both roles and switch between `Need Help` and `Help & Earn` at any time.

## Product Purpose

OnTheWay is a hyperlocal two-sided marketplace for matching local micro-tasks to nearby people who are already traveling in a compatible direction. Success means a requester can publish and safely complete a task quickly while the selected helper takes a minimal detour.

## Positioning

The primary matching signal is route overlap and detour cost, not raw distance to pickup: “Don’t find someone to make the trip. Find someone already making the trip.”

## Operating Context

Typical tasks include prepaid food or coffee pickup, small-item pickup and delivery, store pickup, and package return or drop-off. Core use happens while walking, biking, driving, commuting, returning home, or staying nearby. Exact addresses are withheld until a match is accepted.

## Capabilities and Constraints

- Unified identity with requester/helper mode switching.
- Map and list discovery for available helpers and open tasks.
- Helper availability setup includes categories, transport, radius, and intended destination.
- Dynamic category-specific task forms and transparent suggested pricing.
- Automatic matching and direct requests; helpers always accept or decline.
- Escrow-style authorization before work, progress tracking, chat, completion confirmation, rating, wallet, activity, notifications, and reputation.
- Location shown before matching must be approximate. Exact pickup/drop-off details appear only after a match.
- The current build uses realistic local sample data and simulated task/payment state; it does not connect to production location, payment, identity, chat, or notification services.

## Brand Commitments

- Product name: OnTheWay.
- The supplied prototype is the visual authority.
- Voice is calm, direct, trustworthy, local, and human.

## Evidence on Hand

- Product and interaction requirements: `/Users/yanqingyu/.codex/attachments/f19674dc-51ae-4490-8432-d11a0df64286/pasted-text.txt`.
- Twenty-screen high-fidelity reference prototype: `/Users/yanqingyu/Documents/trae_projects/on the way marketplace/`.
- Demo names, prices, addresses, ratings, transaction values, and performance numbers are illustrative rather than production claims.

## Product Principles

1. Optimize for the smallest added distance and time, not the nearest person.
2. Reveal sensitive location details progressively and only when the task requires them.
3. Keep both sides in control: request, accept, modify by consent, and provide transparent cancellation outcomes.
4. Make pricing, payment holds, helper earnings, and task progress easy to understand.
5. Earn trust through identity, reputation, communication, and clear recovery paths.

## Accessibility & Inclusion

The native interface must support Dynamic Type, VoiceOver labels and values, Reduce Motion, sufficient contrast, 44-point touch targets, safe areas, and light/dark appearances.
