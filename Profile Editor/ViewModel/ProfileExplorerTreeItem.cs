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

namespace GadrocsWorkshop.Helios.ProfileEditor.ViewModel
{
    using GadrocsWorkshop.Helios;
    using GadrocsWorkshop.Helios.Controls;
    using System;
    using System.Collections.Generic;

    public class ProfileExplorerTreeItem : NotificationObject
    {
        private WeakReference _parent;

        private ProfileExplorerTreeItemType _includeTypes;

        private string _name;
        private string _description;

        private object _item;
        private ProfileExplorerTreeItemType _itemType;
        private ProfileExplorerTreeItemCollection _children;

        private bool _isSelected;
        private bool _isExpanded;

        private ProfileExplorerInterfaceHierarchy _interfaces;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="profile"></param>
        /// <param name="includeTypes">is a mask of all the sorts of items to show, and differs between the profile explorer, bindings panels, etc.</param>
        public ProfileExplorerTreeItem(HeliosProfile profile, ProfileExplorerTreeItemType includeTypes)
            : this(profile.Name, "", null, includeTypes)
        {
            _item = profile;
            _itemType = ProfileExplorerTreeItemType.Profile;

            if (includeTypes.HasFlag(ProfileExplorerTreeItemType.Monitor))
            {
                ProfileExplorerTreeItem monitors = new ProfileExplorerTreeItem("Monitors", profile.Monitors, this, includeTypes);
                if (monitors.HasChildren)
                {
                    Children.Add(monitors);
                }
            }

            if (includeTypes.HasFlag(ProfileExplorerTreeItemType.Interface))
            {
                _interfaces = new ProfileExplorerInterfaceHierarchy(this, profile, includeTypes);
                if (_interfaces.HasChildren)
                {
                    // if collection of interfaces is not empty (has children), add the whole collection to our children (as one node)
                    Children.Add(_interfaces.Root);
                }
                profile.Interfaces.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Interfaces_CollectionChanged);
            }
        }

        void Interfaces_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            _interfaces.ProcessChanges(e);
            if (_interfaces.HasChildren && (!HasFolder("Interfaces")))
            {
                Children.Add(_interfaces.Root);
            }
        }

        public ProfileExplorerTreeItem(HeliosObject hobj, ProfileExplorerTreeItemType includeTypes)
            : this(hobj.Name, "", null, includeTypes)
        {
            _item = hobj;
            _itemType = ProfileExplorerTreeItemType.Visual;

            AddChild(hobj, includeTypes);
        }

        private ProfileExplorerTreeItem(string name, string description, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
        {
            _parent = new WeakReference(parent);
            _name = name;
            _description = description;
            _itemType = ProfileExplorerTreeItemType.Folder;
            _includeTypes = includeTypes;
            _children = new ProfileExplorerTreeItemCollection();
        }

        private ProfileExplorerTreeItem(HeliosInterface heliosInterface, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
            : this(heliosInterface.Name, "", parent, includeTypes)
        {
            _itemType = ProfileExplorerTreeItemType.Interface;
            _item = heliosInterface;

            AddChild(heliosInterface, includeTypes);
        }

        private ProfileExplorerTreeItem(string name, MonitorCollection monitors, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
            : this(name, "", parent, includeTypes)
        {
            _itemType = ProfileExplorerTreeItemType.Folder;
            foreach (Monitor monitor in monitors)
            {
                ProfileExplorerTreeItem monitorItem = new ProfileExplorerTreeItem(monitor, this, includeTypes);
                Children.Add(monitorItem);
            }
        }

        private ProfileExplorerTreeItem(HeliosVisual visual, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
            : this(visual.Name, "", parent, includeTypes)
        {
            if (visual.GetType() == typeof(Monitor))
            {
                _itemType = ProfileExplorerTreeItemType.Monitor;
            }
            else if (visual.GetType() == typeof(HeliosPanel))
            {
                _itemType = ProfileExplorerTreeItemType.Panel;
            }
            else
            {
                _itemType = ProfileExplorerTreeItemType.Visual;
            }
            _item = visual;

            AddChild(visual, includeTypes);

            foreach (HeliosVisual child in visual.Children)
            {
                if ((child is HeliosPanel && _includeTypes.HasFlag(ProfileExplorerTreeItemType.Panel)) ||
                    (child is HeliosVisual && _includeTypes.HasFlag(ProfileExplorerTreeItemType.Visual)))
                {
                    Children.Add(new ProfileExplorerTreeItem(child, this, _includeTypes));
                }
            }

            visual.Children.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(VisualChildren_CollectionChanged);
        }

        // XXX this is a disconnect method, why does it add a bunch of event handlers?  are all these typos or is it really signing up just to get called once right now?
        public void Disconnect()
        {
            switch (ItemType)
            {
                case ProfileExplorerTreeItemType.Monitor:
                case ProfileExplorerTreeItemType.Panel:
                case ProfileExplorerTreeItemType.Visual:
                    HeliosVisual visual = ContextItem as HeliosVisual;
                    visual.PropertyChanged -= new System.ComponentModel.PropertyChangedEventHandler(hobj_PropertyChanged);
                    visual.Children.CollectionChanged -= new System.Collections.Specialized.NotifyCollectionChangedEventHandler(VisualChildren_CollectionChanged);
                    visual.Triggers.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Triggers_CollectionChanged);
                    visual.Actions.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Actions_CollectionChanged);
                    break;
                case ProfileExplorerTreeItemType.Interface:
                    HeliosInterface item = ContextItem as HeliosInterface;
                    item.PropertyChanged -= new System.ComponentModel.PropertyChangedEventHandler(hobj_PropertyChanged);
                    item.Triggers.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Triggers_CollectionChanged);
                    item.Actions.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Actions_CollectionChanged);
                    break;
                case ProfileExplorerTreeItemType.Action:
                    IBindingAction action = ContextItem as IBindingAction;
                    action.Target.InputBindings.CollectionChanged -= Bindings_CollectionChanged;
                    break;
                case ProfileExplorerTreeItemType.Trigger:
                    IBindingTrigger trigger = ContextItem as IBindingTrigger;
                    trigger.Source.OutputBindings.CollectionChanged -= Bindings_CollectionChanged;
                    break;
                case ProfileExplorerTreeItemType.Value:
                    break;
                case ProfileExplorerTreeItemType.Binding:
                    HeliosBinding binding = ContextItem as HeliosBinding;
                    binding.PropertyChanged += Binding_PropertyChanged;
                    break;
                case ProfileExplorerTreeItemType.Profile:
                    HeliosProfile profile = ContextItem as HeliosProfile;
                    profile.PropertyChanged -= new System.ComponentModel.PropertyChangedEventHandler(hobj_PropertyChanged);
                    break;
                default:
                    break;
            }

            foreach (ProfileExplorerTreeItem child in Children)
            {
                child.Disconnect();
            }
        }

        void VisualChildren_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.OldItems != null)
            {
                foreach (HeliosVisual visual in e.OldItems)
                {
                    ProfileExplorerTreeItem child = GetChildObject(visual);
                    if (child != null)
                    {
                        child.Disconnect();
                        Children.Remove(child);
                    }
                }
            }

            if (e.NewItems != null)
            {
                foreach (HeliosVisual child in e.NewItems)
                {
                    if ((child is HeliosPanel && _includeTypes.HasFlag(ProfileExplorerTreeItemType.Panel)) ||
                        (child is HeliosVisual && _includeTypes.HasFlag(ProfileExplorerTreeItemType.Visual)))
                    {
                        Children.Add(new ProfileExplorerTreeItem(child, this, _includeTypes));
                    }
                }
            }
        }

        private ProfileExplorerTreeItem(IBindingAction item, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
            : this(item.ActionName, item.ActionDescription, parent, includeTypes)
        {
            _item = item;
            _itemType = ProfileExplorerTreeItemType.Action;

            //SortName = item.Name + " " + item.ActionVerb;

            if (includeTypes.HasFlag(ProfileExplorerTreeItemType.Binding))
            {

                foreach (HeliosBinding binding in item.Owner.InputBindings)
                {
                    if (binding.Action == item)
                    {
                        Children.Add(new ProfileExplorerTreeItem(binding, this, includeTypes));
                    }
                }
                item.Target.InputBindings.CollectionChanged += Bindings_CollectionChanged;
            }
        }

        void Bindings_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.OldItems != null)
            {
                foreach (HeliosBinding binding in e.OldItems)
                {
                    ProfileExplorerTreeItem child = GetChildObject(binding);
                    if (child != null)
                    {
                        child.Disconnect();
                        Children.Remove(child);
                    }
                }
            }

            if (e.NewItems != null)
            {
                foreach (HeliosBinding child in e.NewItems)
                {
                    if (child.Action == ContextItem || child.Trigger == ContextItem)
                    {
                        ProfileExplorerTreeItem childItem = new ProfileExplorerTreeItem(child, this, _includeTypes);
                        if (_includeTypes.HasFlag(ProfileExplorerTreeItemType.Binding))
                        {
                            IsExpanded = true;
                            Children.Add(childItem);
                        }
                    }
                }
            }
        }

        private ProfileExplorerTreeItem(IBindingTrigger item, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
            : this(item.TriggerName, item.TriggerDescription, parent, includeTypes)
        {
            _item = item;
            _itemType = ProfileExplorerTreeItemType.Trigger;

            if (includeTypes.HasFlag(ProfileExplorerTreeItemType.Binding))
            {
                foreach (HeliosBinding binding in item.Owner.OutputBindings)
                {
                    if (binding.Trigger == item)
                    {
                        Children.Add(new ProfileExplorerTreeItem(binding, this, includeTypes));
                    }
                }
                item.Source.OutputBindings.CollectionChanged += Bindings_CollectionChanged;
            }
        }

        private ProfileExplorerTreeItem(HeliosBinding item, ProfileExplorerTreeItem parent, ProfileExplorerTreeItemType includeTypes)
            : this(item.Description, "", parent, includeTypes)
        {
            _item = item;
            _itemType = ProfileExplorerTreeItemType.Binding;
            item.PropertyChanged += Binding_PropertyChanged;
        }

        void Binding_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            if (e.PropertyName.Equals("Name"))
            {
                Name = (_item as HeliosBinding).Description;
            }
        }

        public void ExpandAll()
        {
            IsExpanded = true;
            foreach (ProfileExplorerTreeItem child in Children)
            {
                child.ExpandAll();
            }
        }

        #region Properties

        public bool HasChildren { get { return _children != null && _children.Count > 0; } }

        public ProfileExplorerTreeItem Parent
        {
            get { return _parent.Target as ProfileExplorerTreeItem; }
            private set { _parent = new WeakReference(value); }
        }

        public string Name
        {
            get
            {
                return _name;
            }
            set
            {
                if ((_name == null && value != null)
                    || (_name != null && !_name.Equals(value)))
                {
                    string oldValue = _name;
                    _name = value;
                    OnPropertyChanged("Name", oldValue, value, false);
                }
            }
        }

        public bool IsSelected
        {
            get
            {
                return _isSelected;
            }
            set
            {
                if (!_isSelected.Equals(value))
                {
                    bool oldValue = _isSelected;
                    _isSelected = value;
                    OnPropertyChanged("IsSelected", oldValue, value, false);
                }
            }
        }

        public bool IsExpanded
        {
            get
            {
                return _isExpanded;
            }
            set
            {
                if (!_isExpanded.Equals(value))
                {
                    bool oldValue = _isExpanded;
                    _isExpanded = value;
                    OnPropertyChanged("IsExpanded", oldValue, value, false);
                }
            }
        }

        public string Description
        {
            get
            {
                return _description;
            }
            set
            {
                if ((_description == null && value != null)
                    || (_description != null && !_description.Equals(value)))
                {
                    string oldValue = _description;
                    _description = value;
                    OnPropertyChanged("Description", oldValue, value, false);
                }
            }
        }

        public ProfileExplorerTreeItemType ItemType
        {
            get { return _itemType; }
        }

        public ProfileExplorerTreeItemCollection Children
        {
            get { return _children; }
        }

        public object ContextItem
        {
            get { return _item; }
        }

        #endregion

        private void AddChild(HeliosObject hobj, ProfileExplorerTreeItemType includeTypes)
        {
            hobj.PropertyChanged += new System.ComponentModel.PropertyChangedEventHandler(hobj_PropertyChanged);

            if (includeTypes.HasFlag(ProfileExplorerTreeItemType.Trigger))
            {
                foreach (IBindingTrigger trigger in hobj.Triggers)
                {
                    AddTrigger(trigger, includeTypes);
                }
                hobj.Triggers.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Triggers_CollectionChanged);
            }

            if (includeTypes.HasFlag(ProfileExplorerTreeItemType.Action))
            {
                foreach (IBindingAction action in hobj.Actions)
                {
                    AddAction(action, includeTypes);
                }
                hobj.Actions.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Actions_CollectionChanged);
            }
        }

        void hobj_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            HeliosObject obj = _item as HeliosObject;
            if (e.PropertyName.Equals("Name") && obj != null)
            {
                this.Name = obj.Name;
            }
        }

        void Triggers_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.OldItems != null)
            {
                foreach (IBindingTrigger trigger in e.OldItems)
                {
                    if (trigger.Device.Length > 0)
                    {
                        ProfileExplorerTreeItem folder = GetFolder(trigger.Device);
                        folder.Children.Remove(GetChildObject(trigger));
                        if (folder.Children.Count == 0)
                        {
                            Children.Remove(folder);
                        }
                    }
                    else
                    {
                        Children.Remove(GetChildObject(trigger));
                    }

                }
            }

            if (e.NewItems != null)
            {
                foreach (IBindingTrigger trigger in e.NewItems)
                {
                    AddTrigger(trigger, _includeTypes);
                }
            }

        }

        void Actions_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.OldItems != null)
            {
                foreach (IBindingAction action in e.OldItems)
                {
                    if (action.Device.Length > 0)
                    {
                        ProfileExplorerTreeItem folder = GetFolder(action.Device);
                        folder.Children.Remove(GetChildObject(action));
                        if (folder.Children.Count == 0)
                        {
                            Children.Remove(folder);
                        }
                    }
                    else
                    {
                        Children.Remove(GetChildObject(action));
                    }

                }
            }

            if (e.NewItems != null)
            {
                foreach (IBindingAction action in e.NewItems)
                {
                    AddAction(action, _includeTypes);
                }
            }
        }

        private void AddTrigger(IBindingTrigger trigger, ProfileExplorerTreeItemType includeTypes)
        {

            ProfileExplorerTreeItem triggerItem = new ProfileExplorerTreeItem(trigger, this, includeTypes);
            if (triggerItem.HasChildren || includeTypes.HasFlag(ProfileExplorerTreeItemType.Trigger))
            {
                if (trigger.Device.Length > 0)
                {
                    if (!HasFolder(trigger.Device))
                    {
                        Children.Add(new ProfileExplorerTreeItem(trigger.Device, "", this, includeTypes));
                    }

                    ProfileExplorerTreeItem deviceItem = GetFolder(trigger.Device);
                    triggerItem.Parent = deviceItem;
                    deviceItem.Children.Add(triggerItem);
                }
                else
                {
                    Children.Add(triggerItem);
                }
            }
        }

        public void AddAction(IBindingAction action, ProfileExplorerTreeItemType includeTypes)
        {
            ProfileExplorerTreeItem actionItem = new ProfileExplorerTreeItem(action, this, includeTypes);
            if (actionItem.HasChildren || includeTypes.HasFlag(ProfileExplorerTreeItemType.Action))
            {
                if (action.Device.Length > 0)
                {
                    if (!HasFolder(action.Device))
                    {
                        Children.Add(new ProfileExplorerTreeItem(action.Device, "", this, includeTypes));
                    }

                    ProfileExplorerTreeItem deviceItem = GetFolder(action.Device);
                    actionItem.Parent = deviceItem;
                    deviceItem.Children.Add(actionItem);
                }
                else
                {
                    Children.Add(actionItem);
                }
            }
        }

        private bool HasFolder(string folderName)
        {
            return GetFolder(folderName) != null;
        }

        private ProfileExplorerTreeItem GetFolder(string folderName)
        {
            foreach (ProfileExplorerTreeItem child in Children)
            {
                if (child.Name.Equals(folderName) && child.ItemType == ProfileExplorerTreeItemType.Folder)
                {
                    return child;
                }
            }
            return null;
        }

        private bool HasChildObject(HeliosObject childObject)
        {
            return GetChildObject(childObject) != null;
        }

        private ProfileExplorerTreeItem GetChildObject(object childObject)
        {
            foreach (ProfileExplorerTreeItem child in Children)
            {
                if (child.ContextItem == childObject)
                {
                    return child;
                }
            }
            return null;
        }

        // NOTE: implemented as nested class because basically everything we need in ProfileExplorerTreeItem is private
        private class ProfileExplorerInterfaceHierarchy
        {
            public bool HasChildren { get => Root.HasChildren; }

            private ProfileExplorerTreeItemType _includeTypes;

            public ProfileExplorerTreeItem Root { get; internal set; }

            // interfaces for which we have yet to find the parent, indexed by parent type ID
            private Dictionary<string, List<HeliosInterface>> _orphans = new Dictionary<string, List<HeliosInterface>>();

            // active tree nodes, by type ID
            private Dictionary<string, List<ProfileExplorerTreeItem>> _active = new Dictionary<string, List<ProfileExplorerTreeItem>>();

            public ProfileExplorerInterfaceHierarchy(ProfileExplorerTreeItem parent, HeliosProfile profile, ProfileExplorerTreeItemType includeTypes)
            {
                _includeTypes = includeTypes;
                Root = new ProfileExplorerTreeItem("Interfaces", "", parent, includeTypes);
                foreach (HeliosInterface heliosInterface in profile.Interfaces)
                {
                    AddItem(heliosInterface);
                }
            }

            internal void ProcessChanges(System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
            {
                if (e.OldItems != null)
                {
                    foreach (HeliosInterface heliosInterface in e.OldItems)
                    {
                        RemoveItem(heliosInterface);
                    }
                }

                if (e.NewItems != null)
                {
                    foreach (HeliosInterface heliosInterface in e.NewItems)
                    {
                        AddItem(heliosInterface);
                    }
                }
            }

            private void AddItem(HeliosInterface newInterface)
            {
                // get meta information
                HeliosInterfaceDescriptor interfaceInfo = ConfigManager.ModuleManager.InterfaceDescriptors[newInterface.TypeIdentifier];
                if (interfaceInfo.ParentTypeIdentifier != null)
                {
                    // sub interface
                    if (_active.TryGetValue(interfaceInfo.ParentTypeIdentifier, out List<ProfileExplorerTreeItem> interfaceParents))
                    {
                        // look for specific parent
                        foreach (ProfileExplorerTreeItem stranger in interfaceParents)
                        {
                            if (stranger._item == newInterface.ParentInterface)
                            {
                                // found it
                                DoAdd(stranger, newInterface);
                                ConfigManager.LogManager.LogDebug($"child interface {newInterface.Name} added to tree");
                                return;
                            }
                        }
                        // ran out of possible parents, need to wait
                        ConfigManager.LogManager.LogDebug($"child interface {newInterface.Name} cannot be added yet, because its parent is not in the tree; deferring as orphan");
                        StoreOrphan(newInterface, newInterface.TypeIdentifier);
                    }
                }
                else
                {
                    // top-level interface, can just add
                    DoAdd(Root, newInterface);
                    ConfigManager.LogManager.LogDebug($"interface {newInterface.Name} added to tree");
                }
            }

            private void RemoveItem(HeliosInterface item)
            {
                // find object
                if (_active.TryGetValue(item.TypeIdentifier, out List<ProfileExplorerTreeItem> candidates))
                {
                    int index = candidates.FindIndex(candidateItem => candidateItem._item == item);
                    if (index >= 0)
                    {
                        ProfileExplorerTreeItem existing = candidates[index];

                        // now disconnect item
                        existing.Disconnect();

                        // remove from tree
                        existing.Parent.Children.Remove(existing);

                        // unpublish
                        candidates.RemoveAt(index);

                        ConfigManager.LogManager.LogDebug($"interface {item.Name} removed from tree");
                    }
                }
                else
                {
                    ConfigManager.LogManager.LogWarning($"attempt to remove interface {item.Name}, but it was not in tree; ignored");
                }
            }

            private void DoAdd(ProfileExplorerTreeItem parent, HeliosInterface newInterface)
            {
                ProfileExplorerTreeItem item = new ProfileExplorerTreeItem(newInterface, parent, _includeTypes);
                parent.Children.Add(item);
                PublishNode(item, newInterface, newInterface.TypeIdentifier);

                // try to find any affected orphans
                AdoptOrphans(item, newInterface, newInterface.TypeIdentifier);
            }

            private void AdoptOrphans(ProfileExplorerTreeItem item, HeliosInterface newInterface, string typeIdentifier)
            {
                if (_orphans.TryGetValue(typeIdentifier, out List<HeliosInterface> orphans))
                {
                    for (int i = 0; i < orphans.Count; /* no increment */)
                    {
                        HeliosInterface orphan = orphans[i];
                        if (orphan.ParentInterface == newInterface)
                        {
                            // we just added the missing parent, adopt the orphan
                            orphans.RemoveAt(i);
                            // don't increment i, we just shortened the list

                            // recurse
                            ConfigManager.LogManager.LogDebug($"child interface {orphan.Name} is no longer an orphan; adding to tree");
                            DoAdd(item, orphan);
                        }
                        else
                        {
                            // keep scanning
                            i++;
                        }
                    }
                }
            }

            private void PublishNode(ProfileExplorerTreeItem item, HeliosInterface newInterface, string typeIdentifier)
            {
                List<ProfileExplorerTreeItem> published;
                if (!_active.TryGetValue(typeIdentifier, out published))
                {
                    published = new List<ProfileExplorerTreeItem>();
                    _active.Add(typeIdentifier, published);
                } 
                else if (null != published.Find(publishedItem => publishedItem._item == newInterface))
                {
                    ConfigManager.LogManager.LogWarning($"added interface {item.Name} to tree, but it was already there; ignored");
                    return;
                } 
                published.Add(item);
            }

            private void StoreOrphan(HeliosInterface newInterface, string typeIdentifier)
            {
                List<HeliosInterface> orphanage;
                if (!_orphans.TryGetValue(typeIdentifier, out orphanage))
                {
                    orphanage = new List<HeliosInterface>();
                    _orphans.Add(typeIdentifier, orphanage);
                }
                orphanage.Add(newInterface);
            }
        }
    }
}