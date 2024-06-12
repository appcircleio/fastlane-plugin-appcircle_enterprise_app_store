## Appcircle Enterprise App Store

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-appcircle_enterprise_store)

Appcircle Enterprise Mobile App Store is your own mobile app store for providing access to in-house apps with a customizable mobile storefront.

- **Customizable Storefront:** Distribute your in-house apps with a fully customizable mobile storefront.
- **Secure Distribution:** Everything you need for secure, streamlined distribution of your in-house apps.
- **No MDM Required:** Allows distribution of B2B and B2E applications without the need for an MDM solution and enrollment.

Learn more about [Appcircle Enterprise App Store](https://appcircle.io/enterprise-app-store?utm_source=fastlane&utm_medium=plugin&utm_campaign=enterprise_app_store).

## What Sets Apart Appcircle Enterprise Mobile App Store

1. **Direct File Sharing:**
   - **Skip Traditional Stores:** Share .IPA, APK, or AAB files directly, avoiding the need to wait for Apple App Store or Google Play approvals.
2. **Flexible Sharing Options:**
   - **Beta and Live Modes:** Share your app in ‘beta’ mode for testing new features or identifying bugs, or in ‘live’ mode for stable versions. This flexibility helps maintain the development lifecycle without interruptions.
3. **Enhanced Security:**
   - **Secure Authentication:** Access the Enterprise Mobile App Store with extra secure authentication using Enterprise Authentication Methods.
   - **Controlled Access:** Ensure that only authorized users can access the app store and its contents.
4. **Customizable Mobile Storefront:**
   - **Tailored Experience:** Provide a customizable mobile storefront for your in-house apps, ensuring a tailored experience that aligns with your brand and user needs.
5. **No MDM Requirement:**
   - **Simplified Distribution:** Distribute B2B and B2E applications without the need for a Mobile Device Management (MDM) solution or enrollment, reducing complexity and costs.
6. **Streamlined Workflow:**
   - **Seamless Integration:** Integrates smoothly with your existing workflow, making it easy to manage and distribute apps within your organization.
   - **Efficient Management:** Track and manage applications, versions, testers, and teams effectively, ensuring a smooth distribution process.

These features make the Appcircle Enterprise Mobile App Store a powerful tool for securely and efficiently distributing in-house applications, offering flexibility, enhanced security, and a streamlined workflow.

![Enterprise App Store Dashboard](https://cdn.appcircle.io/docs/assets/entstore-profilelist.png)

### Generating/Managing the Personal API Tokens

To generate a Personal API Token:

1. Go to the My Organization screen (second option at the bottom left).
2. Find the Personal API Token section in the top right corner.
3. Press the "Generate Token" button to generate your first token.

![Token Generation](<https://cdn.appcircle.io/docs/assets/image%20(164).png>)

### Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `appcircle_enterprise_store`, add it to your project by running:

```bash
fastlane add_plugin appcircle_enterprise_store
```

After adding the plugin to your project, configure your Fastfile as follows:

```yml
  lane :distribute_app_store do
    appcircle_enterprise_store(
      accessToken: "$(AC_ACCESS_TOKEN)",
      entProfileId: "$(ENTERPRISE_PROFILE_ID)",
      appPath: "$(APP_PATH)",
      summary: "$(SUMMARY)",
      releaseNotes: "$(RELEASE_NOTE)",
      publishType: "$(PUBLISH_TYPE)" # Assign the appropriate number based on the status: None (0), Beta (1), Live (2)
    )
  end
```

### Leveraging Environment Variables

Utilize environment variables seamlessly by substituting the parameters with $(VARIABLE_NAME) in your task inputs. The extension automatically retrieves values from the specified environment variables within your pipeline.

If you would like to learn more about this extension and how to utilize it in your projects, please [contact us](https://appcircle.io/contact?utm_source=fastlane&utm_medium=plugin&utm_campaign=enterprise_app_store)

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

### Reference

For more detailed instructions and support, visit the [Appcircle Enterprise App Store documentation](https://appcircle.io/enterprise-app-store).
