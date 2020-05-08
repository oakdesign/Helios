﻿//  Copyright 2014 Craig Courtney
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

namespace GadrocsWorkshop.Helios.Splash
{
    using System;
    using System.Windows;
    using System.Windows.Input;

    /// <summary>
    /// Splash screen for Helios, currently also used as about box without any buttons
    /// </summary>
    public partial class About : Window
    {
        public static readonly string[] Authors = { "Gadroc", "BlueFinBima", "derammo" };
        public static readonly string[] Contributors = { "CaptZeen", "KiwiLostInMelb", "Phar71", "damien022", "Will Hartsell", "Cylution", "Rachmaninoff", "yzfanimal", "WillianG83", "wheelchock", "BeamRider", "Jabbers" };

        public About()
        {
            InitializeComponent();
        }

        protected override void OnActivated(EventArgs e)
        {
            Version runningVersion = VersionChecker.RunningVersion;
            VersionBlock.Text = runningVersion.Major.ToString() + "." + runningVersion.Minor.ToString() + "." + runningVersion.Build.ToString() + "." + runningVersion.Revision.ToString("0000");
            ContributionBlock.Text = string.Join("; ", Authors);
            ContributionBlock.Text = ContributionBlock.Text + "; " + string.Join("; ", Contributors);
            StatusBlock.Text = RunningVersion.IsDevelopmentPrototype ? "Development Prototype" : "Released";
            base.OnActivated(e);
        }

        protected override void OnKeyDown(KeyEventArgs e)
        {
            Close();
            base.OnKeyDown(e);
        }

        protected override void OnMouseDown(MouseButtonEventArgs e)
        {
            Close();
            base.OnMouseDown(e);
        }
    }
}
