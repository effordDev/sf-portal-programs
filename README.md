# Prerequisites 

<a href="https://githubsfdeploy.herokuapp.com?owner=effordDev&repo=sf-portal-programs&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

- [Prerequisites](#prerequisites)
- [PortalPrograms LWC](#portalprograms-lwc)
  - [Overview](#overview)
  - [Component Structure](#component-structure)
    - [HTML Template](#html-template)
    - [JavaScript Controller](#javascript-controller)
  - [Attributes and Methods](#attributes-and-methods)
    - [Attributes](#attributes)
    - [Computed Properties](#computed-properties)
    - [Methods](#methods)
      - [`connectedCallback()`](#connectedcallback)
      - [`fetchPortalPrograms()`](#fetchportalprograms)
  - [Usage](#usage)
- [PortalProgramsHelper Apex Class](#portalprogramshelper-apex-class)
  - [Overview](#overview-1)
  - [Security](#security)
  - [Methods](#methods-1)
    - [`getPortalPrograms(String hook)`](#getportalprogramsstring-hook)
    - [`getPortalProgram(String recordId)`](#getportalprogramstring-recordid)
    - [`getRelatedAccounts()`](#getrelatedaccounts)
    - [`getPortalProgramApplications(String recordId)`](#getportalprogramapplicationsstring-recordid)
    - [`createPortalProgramApplication(String recordId, String accountId)`](#createportalprogramapplicationstring-recordid-string-accountid)
  - [Error Handling](#error-handling)
  - [Notes](#notes)

# Prereqs
[Application Module](https://github.com/effordDev/sf-application)

Contacts to Multiple Accounts Settings: `true`

Permission Set Assignments: `Grantmaking Manager`

Permission Set License Assignments: `Grantmaking User, Public Sector Access`

# PortalPrograms LWC

## Overview
The `PortalPrograms` Lightning Web Component is designed to display a list of active portal programs based on a specific hook parameter derived from the current page URL. It retrieves and displays data using the `getPortalPrograms` Apex method and dynamically renders the list of programs, showing a loading spinner and error messages as necessary.

## Component Structure

### HTML Template
- Displays a loading spinner when data is being fetched.
- Shows an error message if data retrieval fails.
- Renders a list of portal programs using the child component `<c-portal-program>`.

### JavaScript Controller
- Uses the `@salesforce/apex` import to call the `getPortalPrograms` method from the `PortalProgramsHelper` Apex class.
- The `NavigationMixin` and `ShowToastEvent` are imported but currently unused, though they could be utilized for navigation and notifications.

## Attributes and Methods

### Attributes

- **isLoading**: A `Boolean` that indicates if data is being loaded (`true` while fetching).
- **error**: A `Boolean` that indicates if there was an error during data retrieval.
- **programs**: An array that stores the list of portal programs retrieved from the Apex class.

### Computed Properties

- **pathname**: Extracts the current URL pathname.
- **pathnameItems**: Splits the `pathname` into an array for easier processing.
- **hook**: Retrieves the last item in `pathnameItems`, which serves as the portal hook parameter for filtering programs.

### Methods

#### `connectedCallback()`
Invoked when the component is added to the DOM. This lifecycle hook calls `fetchPortalPrograms()` to retrieve and display the list of programs.

#### `fetchPortalPrograms()`
An asynchronous method that calls the `getPortalPrograms` Apex method. It:
  - Sets `isLoading` to `true` at the start of data fetching.
  - Uses `hook` as a parameter to retrieve relevant programs.
  - Updates `programs` with the retrieved data.
  - Sets `isLoading` to `false` once data retrieval is complete.
  - Sets `error` to `true` if there’s an exception, logging the error to the console.

## Usage

To include the `PortalPrograms` component in a parent component, use the following markup:

```html
<c-portal-programs></c-portal-programs>

# PortalProgramsHelper Apex Class

## Overview
The `PortalProgramsHelper` class is a utility class designed to manage data for portal programs and related applications. It provides methods for retrieving program details, linked accounts, and handling applications associated with a portal. This class leverages the `@AuraEnabled` annotation to expose its methods to Lightning components, enabling seamless integration with the Salesforce Lightning Experience.

## Security
- All queries use `WITH SECURITY_ENFORCED` to respect field- and object-level security for users.
- The class uses the `with sharing` keyword to enforce sharing rules.

## Methods

### 1. `getPortalPrograms(String hook)`

**Description**: Retrieves a list of active programs filtered by a portal hook.

- **Parameters**:
  - `hook`: A `String` representing the portal hook to filter the programs.
- **Returns**: `List<Program>` - A list of program records matching the given hook.
- **Behavior**: Returns `null` if the `hook` parameter is empty. The list is sorted by `Portal_Display_Order__c`.

### 2. `getPortalProgram(String recordId)`

**Description**: Retrieves a single program by its record ID.

- **Parameters**:
  - `recordId`: A `String` representing the ID of the program.
- **Returns**: `Program` - The program record matching the given ID.
- **Behavior**: Returns `null` if the `recordId` parameter is empty.

### 3. `getRelatedAccounts()`

**Description**: Retrieves active account-contact relations associated with the current user's contact.

- **Returns**: `List<AccountContactRelation>` - A list of active account-contact relations linked to the user's contact.
- **Behavior**: Throws an `AuraHandledException` if the user is not portal-enabled.

### 4. `getPortalProgramApplications(String recordId)`

**Description**: Retrieves active applications for a specific program.

- **Parameters**:
  - `recordId`: A `String` representing the ID of the program.
- **Returns**: `List<Reference_Application__c>` - A list of active reference applications linked to the program.
- **Behavior**: Returns `null` if the `recordId` parameter is empty.

### 5. `createPortalProgramApplication(String recordId, String accountId)`

**Description**: Creates a new application for a specified program and account.

- **Parameters**:
  - `recordId`: A `String` representing the ID of the reference application.
  - `accountId`: A `String` representing the ID of the account.
- **Returns**: `Application__c` - The newly created application record.
- **Behavior**:
  - Checks if the user has permission to create `Application__c` records. 
  - Throws an `AuraHandledException` if the user lacks permission or if there is any error during the creation process.

---

## Error Handling
All methods handle errors gracefully by throwing `AuraHandledException` with appropriate error messages to inform the user of any issues, such as missing permissions or lack of portal access.

---

## Notes
- This class is intended for use in Lightning components, providing the ability to manage and retrieve program data efficiently.
- Review field-level security for all accessed fields to ensure that users have the necessary permissions.
