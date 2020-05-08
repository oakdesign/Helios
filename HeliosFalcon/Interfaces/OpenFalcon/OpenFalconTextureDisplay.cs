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

using System;
using System.Collections.Generic;
using System.IO;
using System.Windows;
using GadrocsWorkshop.Helios.Util;

namespace GadrocsWorkshop.Helios.Interfaces.Falcon.OpenFalcon
{
    public abstract class OpenFalconTextureDisplay : HeliosVisual
    {
        protected enum FalconTextures
        {
            HUD,
            PFL,
            DED,
            RWR,
            MFDLeft,
            MFDRight
        }

        private bool _isRunning = false;

        private Dictionary<FalconTextures, Rect> _textureRectangles = new Dictionary<FalconTextures, Rect>();
        private SharedMemory _textureMemory;

        protected OpenFalconTextureDisplay(string name, Size defaultSize)
            : base(name, defaultSize)
        {
        }

        #region Properties

        internal SharedMemory TextureMemory
        {
            get { return _textureMemory; }
        }

        public bool IsRunning
        {
            get
            {
                return _isRunning;
            }
            set
            {
                if (!_isRunning.Equals(value))
                {
                    bool oldValue = _isRunning;

                    _isRunning = value;
                    OnPropertyChanged("IsRunning", oldValue, value, false);

                    OnDisplayUpdate();
                }
            }
        }

        protected abstract Rect DefaultRect { get; }

        protected abstract FalconTextures Texture { get; }

        internal abstract String DefaultImage { get; }

        internal Rect TextureRect
        {
            get
            {
                if (_textureRectangles.ContainsKey(Texture))
                {
                    return _textureRectangles[Texture];
                }
                else
                {
                    return DefaultRect;
                }
            }
        }

        #endregion

        protected override void OnProfileChanged(HeliosProfile oldProfile)
        {
            base.OnProfileChanged(oldProfile);
            if (oldProfile != null)
            {
                oldProfile.ProfileStarted -= new EventHandler(Profile_ProfileStarted);
                oldProfile.ProfileTick -= new EventHandler(Profile_ProfileTick);
                oldProfile.ProfileStopped -= new EventHandler(Profile_ProfileStopped);
            }

            if (Profile != null)
            {
                Profile.ProfileStarted += new EventHandler(Profile_ProfileStarted);
                Profile.ProfileTick += new EventHandler(Profile_ProfileTick);
                Profile.ProfileStopped += new EventHandler(Profile_ProfileStopped);
            }
        }

        void Profile_ProfileStopped(object sender, EventArgs e)
        {
            _textureMemory.Close();
            _textureMemory.Dispose();
            _textureMemory = null;

            IsRunning = false;
        }

        void Profile_ProfileTick(object sender, EventArgs e)
        {
            if (_textureMemory != null && _textureMemory.IsDataAvailable)
            {
                OnDisplayUpdate();
            }
        }

        void Profile_ProfileStarted(object sender, EventArgs e)
        {
            if (Parent != null && Parent.Profile != null && Parent.Profile.Interfaces.ContainsKey("Falcon"))
            {
                FalconInterface falconInterface = Parent.Profile.Interfaces["Falcon"] as FalconInterface;
                if (falconInterface != null)
                {
                    ParseDatFile(falconInterface.CockpitDatFile);
                }
            }

            _textureMemory = new SharedMemory("FalconTexturesSharedMemoryArea");
            _textureMemory.CheckValue = 0;
            _textureMemory.Open();

            IsRunning = true;
        }

        private void ParseDatFile(string datFile)
        {
            _textureRectangles.Clear();
            if (File.Exists(datFile))
            {
                StreamReader reader = new StreamReader(datFile);
                while (!reader.EndOfStream)
                {
                    string line = reader.ReadLine();
                    string[] tokens = line.Split(new string[] { " ", "\t" }, StringSplitOptions.RemoveEmptyEntries);

                    if (tokens.Length > 1)
                    {
                        switch (tokens[0].ToLower())
                        {
                            case "hud":
                                _textureRectangles.Add(FalconTextures.HUD, ParseRttRectangle(tokens));
                                break;

                            case "pfl":
                                _textureRectangles.Add(FalconTextures.PFL, ParseRttRectangle(tokens));
                                break;

                            case "ded":
                                _textureRectangles.Add(FalconTextures.DED, ParseRttRectangle(tokens));
                                break;

                            case "rwr":
                                _textureRectangles.Add(FalconTextures.RWR, ParseRttRectangle(tokens));
                                break;

                            case "mfdleft":
                                _textureRectangles.Add(FalconTextures.MFDLeft, ParseRttRectangle(tokens));
                                break;

                            case "mfdright":
                                _textureRectangles.Add(FalconTextures.MFDRight, ParseRttRectangle(tokens));
                                break;
                        }
                    }
                }
            }
        }

        private Rect ParseRttRectangle(string[] tokens)
        {
            int rttX1 = int.Parse(tokens[10]);
            int rttX2 = int.Parse(tokens[12]);
            int rttY1 = int.Parse(tokens[11]);
            int rttY2 = int.Parse(tokens[13]);

            return new Rect(rttX1, rttY1, rttX2 - rttX1, rttY2 - rttY1);
        }

        public override void MouseDown(Point location)
        {
            // No-Op
        }

        public override void MouseDrag(System.Windows.Point location)
        {
            // No-Op
        }

        public override void MouseUp(System.Windows.Point location)
        {
            // No-Op
        }

    }
}
