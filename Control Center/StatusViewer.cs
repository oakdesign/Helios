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
using System.Collections.ObjectModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace GadrocsWorkshop.Helios.ControlCenter
{
    public class StatusViewer: DependencyObject, ILogConsumer
    {
        // about two lines of status message are allowed, the rest will be cut if from log
        private const int STATUS_LIMIT = 120;

        private Queue<StatusReportItem> _items = new Queue<StatusReportItem>();
        private LinkedList<StatusReportItem> _shown = new LinkedList<StatusReportItem>();
        private HashSet<string> _uniqueLogMessages = new HashSet<string>();

        // maximum
        private int _capacity = 200;

        // these currently do nothing, but would support internal scrolling, i.e. having more items stored than we give to WPF
        // REVISIT remove or actually use
        private int _windowBase = 0;
        private int _windowSize;

        public class StatusTemplateSelector : DataTemplateSelector
        {
            public override DataTemplate SelectTemplate(object item, DependencyObject container)
            {
                StatusReportItem listItem = item as StatusReportItem;
                FrameworkElement element = container as FrameworkElement;
                if (listItem == null)
                {
                    return null;
                }
                return element.FindResource(listItem.Severity.ToString()) as DataTemplate;
            }
        }

        public static RoutedUICommand ClearCommand { get; } = new RoutedUICommand("Clear Status", "Clear", typeof(StatusViewer));

        public StatusViewer()
        {
            // as long as we don't use these, this needs to be set to max
            _windowSize = _capacity;

            // don't use default generated dependency property, we need our own copy
            Items = new ObservableCollection<StatusReportItem>();

            // register as a log consumer (NOTE: we never deregister)
            ConfigManager.LogManager.RegisterConsumer(this);
        }

        public void AddItem(StatusReportItem item)
        {
            _items.Enqueue(item);
            switch (item.Severity)
            {
                case StatusReportItem.SeverityCode.Info:
                    break;
                case StatusReportItem.SeverityCode.Warning:
                    // fall through
                case StatusReportItem.SeverityCode.Error:
                    CautionLightVisibility = Visibility.Visible;
                    break;
            }

            // if visible, display new item
            if (_windowBase + _windowSize >= _items.Count)
            {
                _shown.AddLast(item);
                Items.Add(item);

                // may have scrolled something off
                while (_shown.Count > _windowSize)
                {
                    Items.Remove(_shown.First.Value);
                    _shown.RemoveFirst();
                }
            }

            // finally, check if we exceeded our capacity
            while (_items.Count > _capacity)
            {
                StatusReportItem discard = _items.Dequeue();
                if (_windowBase == 0)
                {
                    Items.Remove(discard);
                    _shown.RemoveFirst();
                }
                _windowBase--;
            }
        }

        public void Clear()
        {
            _items.Clear();
            _shown.Clear();
            _uniqueLogMessages.Clear();
            _windowBase = 0;
            Items.Clear();
            ResetCautionLight();
        }

        public void ResetCautionLight()
        {
            CautionLightVisibility = Visibility.Hidden;
        }

        public void WriteLogMessage(string timeStamp, LogLevel level, string message, Exception exception)
        {
            StatusReportItem.SeverityCode code;
            switch (level)
            {
                case LogLevel.Warning:
                    code = StatusReportItem.SeverityCode.Warning;
                    break;
                case LogLevel.Error:
                    code = StatusReportItem.SeverityCode.Error;
                    break;
                default:
                    // don't include info messages
                    return;
            }
            if (_uniqueLogMessages.Contains(message))
            {
                // don't include a message more than once
                return;
            }
            _uniqueLogMessages.Add(message);
            // shorten multiline messages, taking at most one line
            string trimmedMessage = message.Substring(0, STATUS_LIMIT);
            int newline = trimmedMessage.IndexOf('\n');
            while (newline >= 0)
            {
                if (newline == 0)
                {
                    // trim from front and continue
                    trimmedMessage = trimmedMessage.Substring(1);
                    newline = trimmedMessage.IndexOf('\n');
                }
                else
                {
                    // found something
                    trimmedMessage = trimmedMessage.Substring(0, newline);
                    break;
                }
            }
            string recommendation = null;
            if (trimmedMessage.Length < message.Length)
            {
                recommendation = "Log message was shortened.  See application log for details.";
            }
            if (exception != null)
            {
                recommendation = $"An exception was thrown: '{exception.Message}'.  You should file a bug.";
            }
            StatusReportItem item = new StatusReportItem()
            {
                TimeStamp = timeStamp,
                Severity = code,
                Status = trimmedMessage,
                Recommendation = recommendation
            };
            AddItem(item);
        }

        public StatusTemplateSelector TemplateSelector { get; } = new StatusTemplateSelector();

        /// <summary>
        /// state of master caution light
        /// </summary>
        public Visibility CautionLightVisibility
        {
            get { return (Visibility)GetValue(CautionLightVisibilityProperty); }
            set { SetValue(CautionLightVisibilityProperty, value); }
        }
        public static readonly DependencyProperty CautionLightVisibilityProperty =
            DependencyProperty.Register("CautionLightVisibility", typeof(Visibility), typeof(StatusViewer), new PropertyMetadata(Visibility.Hidden));

        public ObservableCollection<StatusReportItem> Items
        {
            get { return (ObservableCollection<StatusReportItem>)GetValue(ItemsProperty); }
            set { SetValue(ItemsProperty, value); }
        }
        public static readonly DependencyProperty ItemsProperty =
            DependencyProperty.Register("observableCollection", typeof(ObservableCollection<StatusReportItem>), typeof(StatusViewer), new PropertyMetadata(null));
    }
}