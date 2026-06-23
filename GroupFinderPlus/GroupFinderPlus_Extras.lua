GF = GroupFinderPlus

function GF:AllowAllRoles()
    if not GF.Settings.AllowAllRoles then return end

    ZO_PreHook(GROUP_FINDER_SEARCH_MANAGER, 'ExecuteSearch', function()
        SetGroupFinderFilterEnforceRoles(false)
    end)
end

function GF:FixAchievements()
    if not GF.Settings.FullAchievements then return end
	
    ZO_PreHook(Achievement, 'ApplyCollapsedDescriptionConstraints', function(self)
        if self.IsInstanceOf and self:IsInstanceOf(PopupAchievement) then
            return true
        end
        return false
    end)
    
    ZO_PostHook(PopupAchievement, 'Show', function(self, id, progress, timestamp)
        self.collapsed = false
       
        self:RemoveCollapsedDescriptionConstraints()
        
        self:RefreshExpandedView()

        local container = self.parentControl
        if container then
            container:SetHeight(self.control:GetHeight())
        end
    end)
    
    ZO_PreHook(PopupAchievement, 'Collapse', function(self)
        return true
    end)
    
end

function GF:RegisterBlacklistDialog()
    ZO_CreateStringId("GF_BLACKLIST_DIALOG_HEADER", "Blacklist Confirmation")

    ESO_Dialogs["GF_BLACKLIST_CONFIRMATION_DIALOG"] = {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = "Blacklist Player",
        },
        mainText = {
            text = function(dialog)
                return dialog.data.mainText
            end,
        },
        mustChoose = true,
        buttons = {
            [1] = {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    if dialog.data.callback then
                        dialog.data.callback()
                    end
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
            },
        },
        finishedCallback = function(dialog)
            if dialog.data.finishingCallback then
                dialog.data.finishingCallback()
            end
        end,
    }
end