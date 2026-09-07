#!/usr/bin/env python3
"""
Skrypt generuje minimalny plik project.pbxproj dla projektu orgNIZWE.
Uruchom na Macu lub w środowisku z Pythonem 3.
"""

import uuid
import os
import json


def new_uuid():
    return uuid.uuid4().hex.upper()[:24]


def pbxproj_content():
    # Główne identyfikatory
    project_uuid = new_uuid()
    main_group_uuid = new_uuid()
    app_target_uuid = new_uuid()
    app_build_config_list_uuid = new_uuid()
    app_build_config_debug_uuid = new_uuid()
    app_build_config_release_uuid = new_uuid()
    app_sources_build_phase_uuid = new_uuid()
    app_resources_build_phase_uuid = new_uuid()
    app_frameworks_build_phase_uuid = new_uuid()
    product_ref_uuid = new_uuid()
    info_plist_file_ref = new_uuid()
    assets_file_ref = new_uuid()
    
    # Widget target
    widget_target_uuid = new_uuid()
    widget_build_config_list_uuid = new_uuid()
    widget_build_config_debug_uuid = new_uuid()
    widget_build_config_release_uuid = new_uuid()
    widget_sources_build_phase_uuid = new_uuid()
    widget_resources_build_phase_uuid = new_uuid()
    widget_product_ref_uuid = new_uuid()
    widget_extension_plist_ref = new_uuid()
    
    # Pliki źródłowe aplikacji
    app_swift_files = []
    app_root = "orgNIZWE"
    for root, dirs, files in os.walk(app_root):
        dirs.sort()
        for f in sorted(files):
            if f.endswith(".swift"):
                rel_path = os.path.join(root, f).replace("\\", "/")
                app_swift_files.append((rel_path, new_uuid(), new_uuid()))
    
    # Pliki widgetów
    widget_swift_files = []
    widget_root = "orgNIZWEWidgets"
    for root, dirs, files in os.walk(widget_root):
        dirs.sort()
        for f in sorted(files):
            if f.endswith(".swift"):
                rel_path = os.path.join(root, f).replace("\\", "/")
                widget_swift_files.append((rel_path, new_uuid(), new_uuid()))
    
    # Grupy folderów
    groups = {}
    def get_group(path):
        if path in groups:
            return groups[path]
        groups[path] = new_uuid()
        return groups[path]
    
    get_group("orgNIZWE")
    get_group("orgNIZWEWidgets")
    
    # Build files dla aplikacji
    app_source_build_files = []
    for rel_path, file_ref, build_file in app_swift_files:
        app_source_build_files.append((rel_path, file_ref, build_file))
    
    # Build files dla widgetów
    widget_source_build_files = []
    for rel_path, file_ref, build_file in widget_swift_files:
        widget_source_build_files.append((rel_path, file_ref, build_file))
    
    # Sekcja PBXBuildFile
    build_files = []
    for rel_path, file_ref, build_file in app_source_build_files:
        build_files.append(f"\t\t{build_file} /* in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {os.path.basename(rel_path)} */; }};")
    for rel_path, file_ref, build_file in widget_source_build_files:
        build_files.append(f"\t\t{build_file} /* in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {os.path.basename(rel_path)} */; }};")
    
    # Sekcja PBXFileReference
    file_refs = []
    for rel_path, file_ref, _ in app_source_build_files:
        file_refs.append(f"\t\t{file_ref} /* {os.path.basename(rel_path)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{rel_path}\"; sourceTree = \"<group>\"; }};")
    for rel_path, file_ref, _ in widget_source_build_files:
        file_refs.append(f"\t\t{file_ref} /* {os.path.basename(rel_path)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{rel_path}\"; sourceTree = \"<group>\"; }};")
    
    file_refs.append(f"\t\t{info_plist_file_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
    file_refs.append(f"\t\t{assets_file_ref} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};")
    file_refs.append(f"\t\t{widget_extension_plist_ref} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; name = Info.plist; path = orgNIZWEWidgets/Info.plist; sourceTree = \"<group>\"; }};")
    file_refs.append(f"\t\t{product_ref_uuid} /* orgNIZWE.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = orgNIZWE.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
    file_refs.append(f"\t\t{widget_product_ref_uuid} /* orgNIZWEWidgets.appex */ = {{isa = PBXFileReference; explicitFileType = \"wrapper.app-extension\"; includeInIndex = 0; path = orgNIZWEWidgets.appex; sourceTree = BUILT_PRODUCTS_DIR; }};")
    
    # Sekcja PBXFrameworksBuildPhase
    frameworks_phase = f"""\t\t{app_frameworks_build_phase_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""
    
    # Sekcja PBXGroups
    # Grupa główna
    groups_content = []
    groups_content.append(f"""\t\t{main_group_uuid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{info_plist_file_ref} /* Info.plist */,
\t\t\t\t{assets_file_ref} /* Assets.xcassets */,
{chr(10).join([f"\t\t\t\t{file_ref} /* {os.path.basename(rel_path)} */," for rel_path, file_ref, _ in app_source_build_files])}
{chr(10).join([f"\t\t\t\t{file_ref} /* {os.path.basename(rel_path)} */," for rel_path, file_ref, _ in widget_source_build_files])}
\t\t\t\t{widget_extension_plist_ref} /* Info.plist */,
\t\t\t\t{product_ref_uuid} /* Products */,
\t\t\t);
\t\t\tsourceTree = \"<group>\";
\t\t}};""")
    
    groups_content.append(f"""\t\t{product_ref_uuid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{product_ref_uuid} /* orgNIZWE.app */,
\t\t\t\t{widget_product_ref_uuid} /* orgNIZWEWidgets.appex */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = \"<group>\";
\t\t}};""")
    
    # Sekcja PBXNativeTarget
    native_targets = f"""\t\t{app_target_uuid} /* orgNIZWE */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {app_build_config_list_uuid} /* Build configuration list for PBXNativeTarget \"orgNIZWE\" */;
\t\t\tbuildPhases = (
\t\t\t\t{app_sources_build_phase_uuid} /* Sources */,
\t\t\t\t{app_frameworks_build_phase_uuid} /* Frameworks */,
\t\t\t\t{app_resources_build_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = orgNIZWE;
\t\t\tproductName = orgNIZWE;
\t\t\tproductReference = {product_ref_uuid} /* orgNIZWE.app */;
\t\t\tproductType = \"com.apple.product-type.application\";
\t\t}};
\t\t{widget_target_uuid} /* orgNIZWEWidgets */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {widget_build_config_list_uuid} /* Build configuration list for PBXNativeTarget \"orgNIZWEWidgets\" */;
\t\t\tbuildPhases = (
\t\t\t\t{widget_sources_build_phase_uuid} /* Sources */,
\t\t\t\t{widget_resources_build_phase_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = orgNIZWEWidgets;
\t\t\tproductName = orgNIZWEWidgets;
\t\t\tproductReference = {widget_product_ref_uuid} /* orgNIZWEWidgets.appex */;
\t\t\tproductType = \"com.apple.product-type.app-extension\";
\t\t}};"""
    
    # Sekcja PBXProject
    project_section = f"""\t\t{project_uuid} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tbuildConfigurationList = {new_uuid()} /* Build configuration list for PBXProject \"orgNIZWE\" */;
\t\t\tcompatibilityVersion = \"Xcode 15.0\";
\t\t\tdevelopmentRegion = pl;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\tpl,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_uuid};
\t\t\tproductRefGroup = {product_ref_uuid} /* Products */;
\t\t\tprojectDirPath = \"\";
\t\t\tprojectRoot = \"\";
\t\t\ttargets = (
\t\t\t\t{app_target_uuid} /* orgNIZWE */,
\t\t\t\t{widget_target_uuid} /* orgNIZWEWidgets */,
\t\t\t);
\t\t}};"""
    
    # Sekcja PBXResourcesBuildPhase
    resources_phase = f"""\t\t{app_resources_build_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{new_uuid()} /* Assets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{widget_resources_build_phase_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""
    
    # Sekcja PBXSourcesBuildPhase
    app_sources = "\n".join([f"\t\t\t\t{build_file} /* {os.path.basename(rel_path)} in Sources */," for rel_path, _, build_file in app_source_build_files])
    widget_sources = "\n".join([f"\t\t\t\t{build_file} /* {os.path.basename(rel_path)} in Sources */," for rel_path, _, build_file in widget_source_build_files])
    
    sources_phase = f"""\t\t{app_sources_build_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{app_sources}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{widget_sources_build_phase_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{widget_sources}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};"""
    
    # Sekcja XCBuildConfiguration
    build_configs = f"""\t\t{app_build_config_debug_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = \"\";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = orgNIZWE/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait\";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t\"$(inherited)\",
\t\t\t\t\t\"@executable_path/Frameworks\",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.orgNIZWE;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{app_build_config_release_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_ASSET_PATHS = \"\";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = orgNIZWE/Info.plist;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = \"UIInterfaceOrientationPortrait\";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t\"$(inherited)\",
\t\t\t\t\t\"@executable_path/Frameworks\",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.orgNIZWE;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{widget_build_config_debug_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = orgNIZWEWidgets/Info.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = orgNIZWEWidgets;
\t\t\t\tINFOPLIST_KEY_NSHumanReadableCopyright = \"\";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t\"$(inherited)\",
\t\t\t\t\t\"@executable_path/Frameworks\",
\t\t\t\t\t\"@executable_path/../../Frameworks\",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.orgNIZWE.widgets;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{widget_build_config_release_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = NO;
\t\t\t\tINFOPLIST_FILE = orgNIZWEWidgets/Info.plist;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = orgNIZWEWidgets;
\t\t\t\tINFOPLIST_KEY_NSHumanReadableCopyright = \"\";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t\"$(inherited)\",
\t\t\t\t\t\"@executable_path/Frameworks\",
\t\t\t\t\t\"@executable_path/../../Frameworks\",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.orgNIZWE.widgets;
\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";
\t\t\t}};
\t\t\tname = Release;
\t\t}};"""
    
    # Sekcja XCConfigurationList
    config_lists = f"""\t\t{app_build_config_list_uuid} /* Build configuration list for PBXNativeTarget \"orgNIZWE\" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{app_build_config_debug_uuid} /* Debug */,
\t\t\t\t{app_build_config_release_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{widget_build_config_list_uuid} /* Build configuration list for PBXNativeTarget \"orgNIZWEWidgets\" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{widget_build_config_debug_uuid} /* Debug */,
\t\t\t\t{widget_build_config_release_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};"""
    
    content = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
{frameworks_phase}
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(groups_content)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
{native_targets}
/* End PBXNativeTarget section */

/* Begin PBXProject section */
{project_section}
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
{resources_phase}
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
{sources_phase}
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
{build_configs}
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
{config_lists}
/* End XCConfigurationList section */
\t}};
\trootObject = {project_uuid} /* Project object */;
}}
"""
    return content


if __name__ == "__main__":
    content = pbxproj_content()
    os.makedirs("orgNIZWE.xcodeproj", exist_ok=True)
    with open("orgNIZWE.xcodeproj/project.pbxproj", "w", encoding="utf-8") as f:
        f.write(content)
    print("Wygenerowano orgNIZWE.xcodeproj/project.pbxproj")
