//  Copyright 2014 Craig Courtney
//    
//  Helios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Helios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

namespace GadrocsWorkshop.Helios.Interfaces.DCS.Common
{
    using GadrocsWorkshop.Helios.UDPInterface;
    using GadrocsWorkshop.Helios.Windows.Controls;
    using Microsoft.Win32;
    using System;
    using System.Globalization;
    using System.Windows;
    using System.Windows.Controls;
    using System.Windows.Data;
    using System.Windows.Input;

    /// <summary>
    /// Interaction logic for DCSInterfaceEditor.xaml
    /// 
    /// This DCS Interface editor can be used by descendants of DCSInterface that do not want to add any specific options.
    /// Using this class will avoid duplicating the XAML.
    /// 
    /// TODO: implement a content container into which specific options can be added.
    /// </summary>
    public partial class DCSInterfaceEditor : HeliosInterfaceEditor
    {
        static DCSInterfaceEditor()
        {
            Type ownerType = typeof(DCSInterfaceEditor);
            CommandManager.RegisterClassCommandBinding(ownerType, new CommandBinding(DCSConfigurator.AddDoFile, AddDoFile_Executed));
            CommandManager.RegisterClassCommandBinding(ownerType, new CommandBinding(DCSConfigurator.RemoveDoFile, RemoveDoFile_Executed));
        }

        public DCSInterfaceEditor()
        {
            InitializeComponent();
            UpdateScriptDirectoryPath();
            Configuration = new DCSConfigurator("DCS F/A-18C", "");
        }

        #region Commands

        private static void AddDoFile_Executed(object target, ExecutedRoutedEventArgs e)
        {
            DCSInterfaceEditor editor = target as DCSInterfaceEditor;
            string file = e.Parameter as string;
            if (editor != null && !string.IsNullOrWhiteSpace(file) && !editor.Configuration.DoFiles.Contains(file))
            {
                editor.Configuration.DoFiles.Add((string)e.Parameter);
                editor.NewDoFile.Text = "";
            }
        }

        private static void RemoveDoFile_Executed(object target, ExecutedRoutedEventArgs e)
        {
            DCSInterfaceEditor editor = target as DCSInterfaceEditor;
            string file = e.Parameter as string;
            if (editor != null && !string.IsNullOrWhiteSpace(file) && editor.Configuration.DoFiles.Contains(file))
            {
                editor.Configuration.DoFiles.Remove(file);
            }
        }
        #endregion

        #region Properties

        public DCSConfigurator Configuration
        {
            get { return (DCSConfigurator)GetValue(ConfigurationProperty); }
            set { SetValue(ConfigurationProperty, value); }
        }
        public static readonly DependencyProperty ConfigurationProperty =
            DependencyProperty.Register("Configuration", typeof(DCSConfigurator), typeof(DCSInterfaceEditor), new PropertyMetadata(null));
        
        /// <summary>
        /// location where we will write Export.lua and related directories, recalculated by calling UpdateScriptDirectoryPath
        /// </summary>
        public string ScriptDirectoryPath
        {
            get { return (string)GetValue(ScriptDirectoryPathProperty); }
        }
        public static readonly DependencyProperty ScriptDirectoryPathProperty =
            DependencyProperty.Register("ScriptDirectoryPath", typeof(String), typeof(DCSInterfaceEditor), new PropertyMetadata(null));

        /// <summary>
        /// if set, we generate the Scripts/Export.lua stub in addition to the files in Scripts/Helios
        /// </summary>
        public bool GenerateExportLoader
        {
            get { return (bool)GetValue(GenerateExportLoaderProperty); }
            set { SetValue(GenerateExportLoaderProperty, value); }
        }
        public static readonly DependencyProperty GenerateExportLoaderProperty =
            DependencyProperty.Register("GenerateExportLoader", typeof(bool), typeof(DCSInterfaceEditor), new PropertyMetadata(true));


        /// <summary>
        /// selected install type 
        /// </summary>
        public InstallType SelectedInstallType {
            get { return (InstallType)GetValue(SelectedInstallTypeProperty); }
            set { SetValue(SelectedInstallTypeProperty, value); }
        }
        public static readonly DependencyProperty SelectedInstallTypeProperty =
            DependencyProperty.Register(
                "SelectedInstallType", 
                typeof(InstallType), 
                typeof(DCSInterfaceEditor), 
                new PropertyMetadata(InstallType.GA, new PropertyChangedCallback(OnInstallTypeSelected)));

        private static void OnInstallTypeSelected(DependencyObject target, DependencyPropertyChangedEventArgs e)
        {
            ((DCSInterfaceEditor)target).UpdateScriptDirectoryPath();
        }

        private void UpdateScriptDirectoryPath()
        {
            SetValue(ScriptDirectoryPathProperty, System.IO.Path.Combine(SavedGamesPath, SavedGamesName, "Scripts"));
        }

        private static Guid FolderSavedGames = new Guid("4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4");

        private string SavedGamesPath
        {
            get
            {
                // We attempt to get the Saved Games known folder from the native method to cater for situations
                // when the locale of the installation has the folder name in non-English.
                IntPtr pathPtr;
                string savedGamesPath;
                int hr = NativeMethods.SHGetKnownFolderPath(ref FolderSavedGames, 0, IntPtr.Zero, out pathPtr);
                if (hr == 0)
                {
                    savedGamesPath = System.Runtime.InteropServices.Marshal.PtrToStringUni(pathPtr);
                    System.Runtime.InteropServices.Marshal.FreeCoTaskMem(pathPtr);
                }
                else
                {
                    savedGamesPath = Environment.GetEnvironmentVariable("userprofile") + "Saved Games";
                }
                return savedGamesPath;
            }
        }

        private string SavedGamesName
        {
            get
            {
                switch (SelectedInstallType)
                {
                    case InstallType.OpenAlpha:
                        return "DCS.OpenAlpha";
                    case InstallType.OpenBeta:
                        return "DCS.OpenBeta";
                    case InstallType.GA:
                    default:
                        return "DCS";
                }
            }
        }

        public bool IsPathValid { get => true; }
        public bool IsUpToDate { get => true; }

        #endregion

        protected override void OnPropertyChanged(DependencyPropertyChangedEventArgs e)
        {
            base.OnPropertyChanged(e);
        }

        private void Configure_Click(object sender, RoutedEventArgs e)
        {
            if (Configuration.UpdateExportConfig())
            {
                MessageBox.Show(Window.GetWindow(this), "DCS F/A-18C has been configured.");
            }
            else
            {
                MessageBox.Show(Window.GetWindow(this), "Error updating DCS F/A-18C configuration.  Please do one of the following and try again:\n\nOption 1) Run Helios as Administrator\nOption 2) Install DCS outside the Program Files Directory\nOption 3) Disable UAC.");
            }
        }

        private void Remove_Click(object sender, RoutedEventArgs e)
        {
            Configuration.RestoreConfig();
        }
    }
}
