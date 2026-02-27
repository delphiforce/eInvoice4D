# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Lingua / Language

**IMPORTANTE: Rispondi SEMPRE in italiano.** L'utente è italiano e preferisce comunicare in italiano.

## Project Overview

**eInvoice4D** is a Delphi library for Italian electronic invoicing (Fatturazione Elettronica), implementing AdE specification version 1.9. It supports both B2B (Privati/FPR12) and Public Administration (PA/FPA12) invoice formats.

## Build Commands

The project uses Delphi's MSBuild system:
```bash
# Build the main package
msbuild packages\delphi\eInvoice4D.dproj

# Build entire project group (package + samples)
msbuild packages\delphi\eInvoice4D_Group.groupproj

# Build specific sample
msbuild samples\InvoiceObject\InvoiceObjectSample.dproj
msbuild samples\SendReceive\SendReceiveSample.dproj
```

Open `packages\delphi\eInvoice4D_Group.groupproj` in Delphi IDE to work with all projects.

## Architecture

### Core Design Pattern: Factory + Registry + Strategy

The library uses interface-based design with GUID identification. All public types are exposed through the main `ei` class in `ei4D.pas`.

### Key Components

```
ei4D.pas (Main facade - all public API)
    │
    ├── Invoice Model (IFatturaElettronicaType)
    │   └── Header + Body structure with property system
    │
    ├── Provider System (IeiProvider)
    │   ├── ei4D.Provider.Aruba.pas
    │   ├── ei4D.Provider.OSItalia.pas
    │   └── ei4D.Provider.Notary.pas
    │
    ├── Validation System (IeiValidator)
    │   ├── ei4D.Validators.Core.pas (vkCore)
    │   ├── ei4D.Validators.XSD.pas (vkXSD)
    │   └── ei4D.Validators.ExtraXSD.pas (vkExtraXSD)
    │
    └── Serialization (IeiSerializer)
        └── XML conversion with sanitization
```

### Property System

The invoice model uses a dynamic property system with RTTI and attributes:
- `[eiProp(id, occurrence, minLen, maxLen)]` - Property metadata
- `[eiBlock]` - Complex nested blocks
- `[eiRegEx]` - Pattern validation
- Occurrence types: `o01` (0-1), `o11` (1-1), `o0N` (0-N), `o1N` (1-N)

### Source Organization

- `source/ei4D.Invoice.*` - Invoice object model and property types
- `source/ei4D.Provider.*` - Provider implementations and registry
- `source/ei4D.Validators.*` - Validation rules and factory
- `source/ei4D.Serializer.*` - XML serialization
- `source/ei4D.Params.*` - Configuration (includes singleton pattern)
- `source/ei4D.Response.*` - Operation result handling
- `source/ei4D.Utils.*` - Utilities (P7M extraction, sanitizer)

## Common Usage Patterns

### Creating an Invoice
```pascal
uses ei4D;

var Invoice := ei.NewInvoice(ftPrivati);  // or ftPubblicaAmministrazione
// Populate header and body...
ei.InvoiceToFile(Invoice, 'output.xml');
```

### Loading and Validating
```pascal
var Invoice := ei.NewInvoiceFromFile('invoice.xml');
var Results := ei.ValidateInvoice(Invoice);
// or validate specific level: ei.ValidateInvoice(Invoice, vkXSD);
```

### Provider Operations
```pascal
var Provider := ei.NewProvider;
Provider.Connect;
Provider.SendInvoice(Invoice);
```

## Dependencies

- Delphi RTL/VCL
- Indy (networking)
- REST Components
- OpenSSL libraries in `libs/openssl/` (1.0.2l and 1.1.1)

## Language

Source code comments and documentation are in Italian. The codebase follows Italian naming conventions for invoice-related terms (Fattura, Cedente, Cessionario, etc.) as per AdE specifications.
