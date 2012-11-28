


(function($) {


     $.ttwNotificationCenter = function(userOptions) {
        var defaults,
                options,
                markup,
                notificationCenter = this ,
                notifications = {},
                menuItems = {},
            //tracks whether there is an increase or decrease in the notification count for a category
                menuItemPrevCount = {},
                MenuItem,
                Notification,
                NotificationList,
                growlWrapper,
                tmpGrowlWrapper,
                categories,
                types,
                cssSelector,
                notificationList,
                colorIndex = 0;

        types = {
            bar:'bar',
            growl:'growl',
            modal:'modal',
            none:'none'
        };

        defaults = {
            notification:{
                type:'bar', //none, growl, modal, bar?
                autoHide:true,
                autoHideDelay:3000
            },
            bar:{
                position:false,
                fullWidth:false
            },
            growl:{
                position:'bottom right'
            },
            modal:{
                position:false,
                buttons: {
                    "Ok": function() {
                        $(this).dialog("close");
                    }
                }
            },
            notificationList:{
                showMenu:true,
                anchor:'bubble',
                offset: '0 24'
            },
            bubble:{
                useColors:true,
                colors:['#f56c7e', '#fec151', '#7ad2f4'],
                showEmptyBubble:true
            },
            markDisplayedRead:true, //Only relevant for notifications associated with a menu category
            showNotificationList:true,
            notificationListEmptyText:'No Notifications',
            defaultCategory : 'general',
            anchor:'body',
            relativeImagePath:'notification_center/images/',
            serverSideSave:false,
            serverSideGet:false,
            serverSideGetNew:false,
            serverSideDelete:false,
            serverSideGetNewInterval:120000,
            serverSideHandler:'sampleHandler.php',
            serverSideSaveCommand:'save',
            serverSideGetCommand:'get',
            serverSideGetNewCommand:'get_new',
            serverSideDeleteCommand:'delete',
            createCallback:function(notification){
            },
            markReadCallback:function(notification){
            },
            deleteCallback:function(notification){
            },
            notificationCountIncrease:function(notification){
            },
            notificationClickCallback:function(notification){
            },
            closeCallback:function(notification){}

        };

        markup = {
            tmp:'<div id="tmp"></div>',
            notification:'<div class="ttw-notification">' +
                    '<span class="icon"></span>' +
                    '<span class="message"></span>' +
                    '<span class="close"></span>' +
                    '</div>',
            notificationIcon:'<img src="" alt="notification icon"/>',
            notificationDialog:'<div class="ttw-notification-modal-inner"></div>',
            notificationBubble:'<span class="notification-bubble" title="Notifications"></span>'
        };

        cssSelector = {
            notification:'.ttw-notification',
            notificationList:'.notification-list',
            notificationListItem:'.notification-list-item',
            notificationMessage:'.message',
            notificationClose:'.close',
            notificationListMenuItem:'.notification-list-menu-item',
            notificationListCloseButton:'.close-notification-list',
            notificationIcon:'.icon',
            notificationModal:'.modal',
            notificationModalOuter:'.ttw-modal-outer',
            notificationBar:'.bar',
            notificationBarOuter:'.ttw-bar-outer',
            notificationGrowlOuter:''
        };

        categories = [];

        //Internal Methods
        function init() {
             options = $.extend(true, {}, defaults, userOptions);

             createCategory(options.defaultCategory);

             if (options.serverSideGetNew && options.serverSideHandler && (options.serverSideHandler != '')) {
                 //query the server for new notifications
                 notificationCenter.getNew();

                 //now we query the server for new notifications at the specified interval
                 setInterval(function() {
                     notificationCenter.getNew();
                 }, options.serverSideGetNewInterval);
             }
         }

        function createCategory(category, menuItem) {
            categories.push(category);

            notifications[category] = {};

            notifications[category].count = 0;
            notifications[category].readCount = 0;
            notifications[category].unreadCount = 0;

            notifications[category].read = {};        //create an empty notifications array for the category
            notifications[category].unread = {};        //create an empty notifications array for the category

            if (menuItem && (category != options.defaultCategory))
                menuItems[category] = menuItem;     //store a reference to the specific menu item for this category
        }

        function registerNotification(notification) {
            // var category = (notification.category) ? notification.category : options.defaultCategory;
            var category = notification.category;

            if (!notifications[category])
                createCategory(category);

            notifications[category].count++;

            //add the notification in the appropriate read/unread bucket
            if (!notification.read) {
                notifications[category].unreadCount++;
                notifications[category].unread[notification.id] = notification;
            }
            else {
                notifications[category].readCount++;
                notifications[category].read[notification.id] = notification;
            }

            //Determine if this notification is a type that should update a bubble, update the appropriate bubble if it is.
            if (logInMenu(category, notification))
                menuItems[category].updateBubble();
        }

        function logInMenu(category, notification) {
            //TODO: combine with update bubble
            //condition 1: Ensure there is a menu item associated with this category
            //condition 2: since the default category isn't associated with a menu item, there is no bubble
            //condition 3: The notification bubble only needs to be updated if this notification doesn't have a display type, or we're not auto marking displayed notifications as read

            return (typeof menuItems[category] != 'undefined') && (category != options.defaultCategory) && (!options.markDisplayedRead || (notification.type == types.none) )
        }

        function unregisterNotification(notification) {
            //We need the textual representation of the read status to access it in the notifications object
            var read_status = notification.read ? 'read' : 'unread';
            delete notifications[notification.category][read_status][notification.id];
            delete notification;
        }

        function isValidCategory(category) {
            //make sure the category is defined and was previously registered
            return category && notifications[category];
        }

        function isValidReadStatus(type) {
            return ($.inArray(type, ['read', 'unread', 'all']) != -1);
        }

        function uniqueId(prefix) {
            //getRandomInt from:https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Math/random
            return  ((typeof prefix != 'undefined') ? prefix : '') + new Date().getTime() + '-' + Math.floor(Math.random() * (100000 - 1 + 1)) + 1;
        }

        function getNotifications(category, readStatus) {

            if (!readStatus)
                readStatus = 'unread';

            //all is the only 'non-valid' category that is allowed. Exit the function if supplied cat isn't valid or all
            if (!(isValidCategory(category) || category == 'all'))
                return false;

            if (!isValidReadStatus(readStatus))
                return false;

            if (category != 'all' && readStatus != 'all') {
                return notifications[category][readStatus];
            }
            else if (category == 'all' && readStatus == 'all') {
                var notifs = {}, tmp = {};

                for (var i = 0; i < categories.length; i++) {
                    $.extend(tmp, notifications[category[i]].read, notifications[category[i]].unread);
                    $.extend(notifs, tmp);
                }

                return notifs;
            }
            else if (category == 'all' && readStatus != 'all') {
                var notifs = {};

                for (var i = 0; i < categories.length; i++) {
                    $.extend(notifs, notifications[categories[i]][readStatus]);
                }
                return notifs;
            }
            else if (category != 'all' && readStatus == 'all') {
                return $.extend({}, notifications[category].read, notifications[category].unread)
            }
            else return false;
        }

        function serverSideGetHandler(data, isNew) {
             try {
                 if (data == '')
                     return false;

                 if(typeof isNew == 'undefined')
                    isNew = true;

                 var result = $.parseJSON(data);

                 if (result.status == 'success') {

                     //If the result is a string then it is not an array of notifications
                     if (result.result != 'empty' && typeof result.result != 'string') {
                         $.each(result.result, function(i, notification) {
                             notificationCenter.createNotification(notification, isNew);
                         });

                         updateAllBubbles();
                     }
                 }
                 else {
                     log('Import Error', result);
                 }
             }
             catch(e) {
                 log('Import Error:', e);
             }

             return true;
         }

        function updateAllBubbles(){
            $.each(menuItems, function(i, menuItem){
               menuItem.updateBubble();
            });
        }

        function runCallback(callback) {
            var functionArgs = Array.prototype.slice.call(arguments, 1);

            if ($.isFunction(callback)) {
                callback.apply(this, functionArgs);
            }
        }

        function log() {
            if (window.console) {
                console.log(Array.prototype.slice.call(arguments));
            }
        }




        //Menu Items
        MenuItem = function(category, selector) {
            this.category = category;
            this.$item = $(selector);
            this.$bubble = {};
            this.notificationList = false;
            this.colors = options.bubble.colors;
            this.init();
        };


        MenuItem.prototype.init = function() {
            var self = this;

            this.createBubble();

            if (options.showNotificationList) {
                this.$bubble.bind('click', function() {
                    if (!self.notificationList) {
                        self.notificationList = new NotificationList({
                            category:self.category,
                            $anchor: (options.notificationList.anchor == 'bubble') ? self.$bubble : self.$item
                        });
                    }
                });
            }

            menuItemPrevCount[this.category] = 0;
        };


        MenuItem.prototype.createBubble = function() {
            this.$bubble = $(markup.notificationBubble).html('0').appendTo(this.$item);

            //give the bubble a background color
            if (options.bubble.useColors) {
                if (colorIndex >= this.colors.length)
                    colorIndex = 0;

                this.$bubble.css('background-color', this.colors[colorIndex]);
                colorIndex++;
            }

            if (options.bubble.showEmptyBubble)
                this.$bubble.css('display', 'inline');
        };


        MenuItem.prototype.updateBubble = function() {
            var self = this,count = (notifications[this.category]) ? notifications[this.category].unreadCount : 0;

            this.$bubble.html(count);

            //there are no unread notidications. Hide teh bubble
            if (count <= 0 && !options.bubble.showEmptyBubble)
                this.$bubble.stop().fadeOut('fast');

            //if there are undread notifications, and the unread count was previously 0, then the bubble will be hidden
            //we need to show it
            if (count > 0 && (menuItemPrevCount[this.category] == 0))
                this.$bubble.stop().fadeIn();

            //The notification count has increased
            if (menuItemPrevCount[this.category] < count)
                runCallback(options.notificationCountIncrease, this);

            menuItemPrevCount[this.category] = count;
        };


        MenuItem.prototype.animate = function(count) {
            //if(menuItemPrevCount[this.category] < count)
            //this.$bubble.sshakeshow('bounce', leftirection:', distance:5up', times:3});
        };




        //Notification List
        NotificationList = function(notificationListOptions) {
            this.$wrapper = {};
            this.$list = false;
            this.type = 'unread';

            this.markup = {
                notificationListWrapper:'<div class="notification-list-wrapper"></div>',
                notificationListMenu:'<ul class="notification-list-menu">' +
                        '<li id="unread-menu-item" class="notification-list-menu-item">Unread</li>' +
                        '<li id="all-menu-item" class="notification-list-menu-item">All</li>' +
                        '<li class="close-notification-list"></li>' +
                        '</ul>',
                notificationListMenuItem:'<li class="notification-list-menu-item"></li>',
                notificationList:'<ul class="notification-list"></ul>',
                notificationListItem:'<li class="notification-list-item"></li>'
            };

            this.settings = $.extend(true, {}, options.notificationList, notificationListOptions);

            if (notificationList) {
                var self = this;
                notificationList.close(function() {
                    self.build();
                });
            }
            else this.build();

            return this;
        };


        NotificationList.prototype.build = function() {
            var $menu;

            this.$wrapper = $(this.markup.notificationListWrapper);

            if (this.settings.showMenu) {
                $menu = $(this.markup.notificationListMenu);
                this.$wrapper.append($menu);
            }

            this.populate();

            this.bindMenuActions();

            this.$wrapper.appendTo(options.anchor).position({
                my:'center top',
                at:'center bottom',
                of:this.settings.$anchor,
                offset: this.settings.offset
            });

            this.$wrapper.css('display', 'block').animate({opacity:1});

            notificationList = this;
        };


        NotificationList.prototype.populate = function() {
            var $list, self = this, theNotifications, listClass;


            $list = $(this.markup.notificationList).attr('data-type', self.type);

            theNotifications = getNotifications(this.settings.category, this.type);

            if (!$.isEmptyObject(theNotifications)) {
                $.each(theNotifications, function(i, notification) {
                    listClass = notification.settings.icon ? 'show-icon' : '';

                    $(self.markup.notificationListItem).addClass(listClass).append(notification.getHtml()).data({
                        id: notification.id,
                        category:notification.category,
                        notification:notification
                    }).appendTo($list);
                });
            }
            else {
                $(self.markup.notificationListItem).addClass('empty-list').html(options.notificationListEmptyText).appendTo($list);
            }

            //bind click action
            $list.find(cssSelector.notificationListItem).bind('click', function(){
                 runCallback(options.notificationClickCallback, $(this).data('notification'));
            });

            if (this.$list)
                this.$list.remove();

            this.$list = $list;
            this.$wrapper.append(this.$list);
        };


        NotificationList.prototype.bindMenuActions = function() {
            var self = this, thisNotification;

            //re-populate the notification list when a menu item is clicked
            this.$wrapper.find(cssSelector.notificationListMenuItem).bind('click', function() {
                self.type = $(this).attr('id').split('-')[0];
                self.populate();
            });

            //handle clicks of mark read
            this.$wrapper.delegate('.close', 'click', function() {
                var $this = $(this);

                $this.parents(cssSelector.notificationListItem).animate({opacity:0}, 400, function() {
                    var $this = $(this), data = $this.data();

                    //we are verifying the existence of each level to prevent an undefined error, which occurs if the button is clicked more than once
                    if (notifications && notifications[data.category] && notifications[data.category][self.type]) {
                        if (notifications[data.category][self.type][data.id]) {
                            thisNotification = notifications[data.category][self.type][data.id].markRead();
                            menuItems[data.category].updateBubble();
                        }
                    }

                    $this.remove();
                    runCallback(options.markReadCallback, thisNotification);
                });
            });

            //handle close button click
            this.$wrapper.find(cssSelector.notificationListCloseButton).bind('click', function() {
                self.close();
            });
        };


        NotificationList.prototype.close = function(callback) {
            var self = this;

            this.$wrapper.fadeOut(50, function() {
                self.$wrapper.remove();
                menuItems[self.settings.category].notificationList = false;
                notificationList = false;
                runCallback(callback);
            });
        };





        //Notifications
        Notification = function(notificationOptions) {
            this.id = '';
            this.message = {};
            this.category = '';
            this.anchor = '';
            this.wrapper = {};
            this.markup = {};
            this.$notification = false; //default to false rather than an empty object so we can easily test if it's been set w/ !this.$notification
            this.hideTimeout = false;
            this.type = '';
            this.read = false;

            //Use the default options if the notification is created with just the message (no other options)
            if (typeof notificationOptions == 'string') {
                this.settings = options.notification;
                this.settings.message = notificationOptions;
            }

            //There is common options object for all notifications as well as a type specific options object.
            //These lines merge the user's options with the type specific object
            var type = notificationOptions.type ? notificationOptions.type : options.notification.type;
            if (type && options[type]) {
                notificationOptions = $.extend({}, options[type], notificationOptions);
            }

            //Create the full options object by merging the options created above with the common options
            this.settings = $.extend(true, {}, options.notification, notificationOptions);
        };


        Notification.prototype.create = function() {

            if (this.settings.message) {

                //give the notification a unique id
                this.id = this.settings.id || uniqueId('notification');
                this.message = this.settings.message;
                this.category = this.settings.category ? this.settings.category : options.defaultCategory;
                this.type = this.settings.type;
                this.data = this.settings.data; //used to store and send additional data about the notification to the server

                //if there is a value for read(perhaps from the db), use it. Otherwise use default
                this.read = (typeof this.settings.read != 'undefined') ? this.settings.read : this.read;

                return this;
            }
            else return false;
        };


        Notification.prototype.html = function() {
            this.$notification = $(markup.notification);

            //remove the icon if this notification does not have one
            if (!this.settings.icon)
                this.$notification.find(cssSelector.notificationIcon).remove();

            //set the notifications id to the id we just created
            this.$notification.attr('id', this.id);

            if (this.settings.notificationClass)
                this.$notification.addClass(this.settings.notificationClass);

            this.setValues();

        };


        Notification.prototype.getHtml = function() {
            //THe notification can be displayed in multiple locations which is the reason for this function. Each location
            //will need its own copy of the html. For example, a notification can be displayed in a notification list
            //and in a modal at the same time
            if (!this.$notification)
                this.html();

            //return a copy of the html, we would just be moving around the same dom element, which won't work if the
            //notification needs to be displayed in multiple places at the same time
            return this.$notification.clone();
        };


        Notification.prototype.setValues = function() {
            //set the notification icon
            if (typeof this.settings.icon != 'undefined')
                this.$notification.addClass('show-icon').find('.icon')
                        .css('background', 'transparent url(' + this.settings.icon + ') no-repeat center center scroll')
                        .html(markup.notificationIcon).find('img').attr('src', this.settings.icon); //attr('src', this.settings.icon);

            //set the notification message
            if (typeof this.message != 'undefined')
                this.$notification.find('.message').html(this.message);
        };


        Notification.prototype.display = function() {
            if (!this.read) {
                //if the notification is going to be displayed to the screen and not logged in a bubble, it shoudl be marked read
                if(!logInMenu(this.category, this))
                    this.markRead();

                switch (this.settings.type) {
                    case types.growl:
                        this.displayGrowl();
                        break;
                    case types.modal:
                        this.displayModal();
                        break;
                    case types.bar:
                        this.displayBar();
                        break;
                    default:
                        break;
                }
            }
        };


        Notification.prototype.setAutoHide = function(notification, inner) {
            var self = this;

            if (options.autoHide || (options.autoHide !== false && this.settings.autoHide !== false))
                this.hideTimeout = setTimeout(function() {
                    self.close(notification, inner);
                }, self.settings.autoHideDelay);
        };


        Notification.prototype.close = function($thisVisualInstance, $inner) {
            if (typeof notifications[this.category][this.id] != undefined) {

                //remove the autoHide timeout if it exists
                if (this.hideTimeout != false)
                    clearTimeout(this.hideTimeout);

                if (!($thisVisualInstance instanceof jQuery))
                    $thisVisualInstance = $($thisVisualInstance);

                $thisVisualInstance.fadeOut(function() {

                    $thisVisualInstance.remove();

                    if($inner)
                        $inner.remove();

                });

                runCallback(options.closeCallback, this);
            }
        };


        Notification.prototype.markRead = function() {
            this.read = true;

            notifications[this.category].readCount++;
            notifications[this.category].read[this.id] = this;

            notifications[this.category].unreadCount--;
            delete notifications[this.category].unread[this.id];

            this.save();

            return this;

        };


        Notification.prototype.save = function() {
            var self = this;

            if (options.serverSideSave && options.serverSideHandler && (options.serverSideHandler != '')) {

                $.ajax({
                    url:options.serverSideHandler,
                    data:{
                        command:    options.serverSideSaveCommand,
                        id:         self.id,
                        message:    self.message,
                        category:   self.category,
                        type:       self.type,
                        read:       self.read,
                        data:       self.data
                    },
                    error:function(jqXHR, textStatus, errorThrown) {
                        log('Save Error: ' + textStatus + ', ' + errorThrown);
                    }
                });
            }
        };


        Notification.prototype.destroy = function(){
            var self = this;

            unregisterNotification(this);

             if (options.serverSideSave && options.serverSideHandler && (options.serverSideHandler != '')) {

                $.ajax({
                    url:options.serverSideHandler,
                    data:{
                        command:    options.serverSideDeleteCommand,
                        id:         self.id
                    },
                    error:function(jqXHR, textStatus, errorThrown) {
                        log('Save Error: ' + textStatus + ', ' + errorThrown);
                    },
                    success:function(){
                        runCallback(options.deleteCallback, self);
                    }
                });
            }
            else  runCallback(options.deleteCallback, self);
        };





        //Growl Notifications
        Notification.prototype.displayGrowl = function() {
            var self = this, $notification;

            this.markup = {
                notification:'<div class="growl-notification">' + '<div class="icon"></div>' + '<div class="message"></div>' + '<span class="close"></span>' + '</div>',
                wrapper:'<div class="ttw-notification-center-wrapper growl-wrapper"></div>'
            };

            if (!growlWrapper)
                this.initGrowl(); else this.wrapper = growlWrapper;


            //display the notification
            $notification = $(this.getHtml());

            $notification.find(cssSelector.notificationClose).click(function() {
                self.close($notification);
            });

            $notification.addClass(this.type).appendTo(this.wrapper).slideDown(300, function() {
                $notification.animate({'opacity': 1}, function() {
                    self.setAutoHide($notification);
                    //runCallback(options.showCallback);
                });
            });

            return this;
        };


        Notification.prototype.initGrowl = function() {
            var position, css = {};

            // this.wrapper = growlWrapper = $(this.markup.wrapper).appendTo(options.anchor);

            //set up the object that will be passed to jQuery css to position the notifications wrapper
            position = this.settings.position.split(' ');
            css[position[0]] = 0;
            css[position[1]] = 0;

            //add the wrapper to the document, position it.
            this.wrapper = growlWrapper = $(this.markup.wrapper).css(css).appendTo(options.anchor);

            //add the tmp wrapper to the document. Notifications are added here first to get height in preparation for animations
            tmpGrowlWrapper = $(markup.tmp).appendTo(options.body);
        };





        //Modal Notification
        Notification.prototype.displayModal = function() {
            var modalClass, modalOptions, position, modal, $window, $outer, self = this;

            modal = $(this.getHtml()).addClass(cssSelector.notificationModal.substr(1));

            modalClass = cssSelector.notificationModalOuter.substr(1);

            if (this.settings.notificationClass)
                modalClass += (' ' + this.settings.notificationClass);

            if (this.settings.icon)
                modalClass += ' show-icon';

            //Make sure the modals always have at least one button
            if(!this.settings.buttons)
                this.settings.buttons = options.modal.buttons;

            //set the modals's position on the screen
            $window = $(window);
            position = this.settings.position || [(($window.width() - 350) / 2), $window.height() * .15];

            modalOptions = {
                dialogClass: modalClass,
                resizable: false,
                title: this.settings.title,
                width:'350',
                position:position,
                modal: true,
                buttons:this.settings.buttons
            };

            modalOptions = $.extend(true, {}, modalOptions, this.settings.dialog);

            modal.dialog(modalOptions);

            $outer = modal.parents(cssSelector.notificationModalOuter);

            this.setAutoHide($outer, modal);
        };





        //Bar Notification
        Notification.prototype.displayBar = function() {

            var $bar, barClass, barOptions, self = this, $outer, position, $window;

            $bar = $(this.getHtml()).addClass(cssSelector.notificationBar.substr(1));

            $bar.find(cssSelector.notificationClose).click(function() {
                self.close($outer);
            });

            barClass = cssSelector.notificationBarOuter.substr(1);

            if (this.settings.icon)
                barClass += ' show-icon';

            if (this.settings.buttons)
                barClass += ' show-buttons';

            if (this.settings.notificationClass)
                barClass += ' ' + this.settings.notificationClass;

            //set the bar's position on the screen
            $window = $(window);
            position = this.settings.position || [(($window.width() - 550) / 2), 6];

            barOptions = {
                dialogClass: barClass,
                resizable: false,
                title: this.settings.title,
                width:'550',
                modal: false,
                buttons:this.settings.buttons,
                position:position
            };

            if (this.settings.buttons)
                barOptions.buttons = this.settings.buttons;

            barOptions = $.extend(true, {}, barOptions, this.settings.dialog);

            $bar.dialog(barOptions);

            //set $outer after the dialog is created, because the $outer element is created by jquery when the dialog is initialized
            $outer = $bar.parent(cssSelector.notificationBarOuter);

            this.setAutoHide($outer, $bar);
        };






        //API
        notificationCenter.createNotification = function(notificationOptions, isNew) {
            var notification = new Notification(notificationOptions);

            //this is used to determine if a notification should be displayed to the screen
            //if a notification is not new, it means it has already been displayed at some point
            isNew = (typeof isNew != 'undefined') ? isNew : true;

            if (notification.create()) {
                registerNotification(notification);

                if(isNew){
                    notification.display();
                    //save the notification to a server side script
                    //TODO: Causing new notifications from the db to generate two xhr requests (other in markRead)
                    notification.save();
                    runCallback(options.createCallback, notification);
                }
            }

            return notification;

        };


        notificationCenter.initMenu = function(menuItems) {
            $.each(menuItems, function(category, selector) {
                var menuItem = new MenuItem(category, selector);
                createCategory(category, menuItem);
            });
        };


        notificationCenter.getNotifications = function(category, type) {
            return getNotifications(category, type);
        };


        notificationCenter.importNotifications = function(category, readStatus){
            if (options.serverSideGet && options.serverSideHandler && (options.serverSideHandler != '')) {
                $.ajax({
                    url:options.serverSideHandler,
                    data:{
                        command:    options.serverSideGetCommand,
                        category:   category,
                        read_status: readStatus
                    },
                    success:function(data){
                        serverSideGetHandler(data, false);
                    },
                    error:function(jqXHR, textStatus, errorThrown) {
                        log('Import Error:', jqXHR, textStatus, errorThrown);
                    }
                });
            }
        };


        notificationCenter.getNew = function(){
             if (options.serverSideGetNew && options.serverSideHandler && (options.serverSideHandler != '')) {
                $.ajax({
                    url:options.serverSideHandler,
                    data:{
                        command: options.serverSideGetNewCommand
                    },
                    success:function(data){
                        serverSideGetHandler(data, true);
                    },
                    error:function(jqXHR, textStatus, errorThrown) {
                        log('Import Error:', jqXHR, textStatus, errorThrown);
                    }
                });
            }
        };


        notificationCenter.deleteNotification = function(notification){
            notification.destroy();
        };


        notificationCenter.notifications = notifications;


        notificationCenter.success = function(message, type, category) {
            return notificationCenter.helper('success', message, type, category);
        };


        notificationCenter.error = function(message, type, category) {
            return notificationCenter.helper('error', message, type, category);
        };


        notificationCenter.notice = function(message, type, category) {
            return notificationCenter.helper('notice', message, type, category);
        };


        notificationCenter.warning = function(message, type, category) {
            return notificationCenter.helper('warning', message, type, category);
        };

         
        notificationCenter.helper = function(helperType, message, type, category) {
            var notification, path;

            if (!type)
                type = options.notification.type;


            path = options.relativeImagePath || '';

            notification = notificationCenter.createNotification({
                message:message,
                type:type,
                category:category,
                title: helperType.charAt(0).toUpperCase() + helperType.slice(1),
                icon:path + helperType + ((type != types.bar) ? '_color' : '') + '.png',
                autoHide:false,
                notificationClass:helperType
            });

            return notification;
        };

        init();

        return notificationCenter;

    };

})(jQuery);