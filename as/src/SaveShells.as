package
{
	import flash.events.Event;
	import net.wg.gui.components.controls.CheckBox;
	import net.wg.gui.components.controls.DropdownMenu;
	import net.wg.gui.components.controls.TextFieldShort;
	import net.wg.gui.components.controls.TextInput;
	import net.wg.infrastructure.base.AbstractWindowView;
	import net.wg.gui.components.controls.SoundButton;
	import flash.events.MouseEvent;
	import net.wg.gui.components.controls.events.DropdownMenuEvent;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.IndexEvent;
	
	public class SaveShells extends AbstractWindowView
	{
		public var onApplyButton : Function = null;
		
		//Основные кнопки
		private var soundButtonOk     : SoundButton;
        private var soundButtonCancel : SoundButton;
		private var soundButtonApply  : SoundButton;
		
		//Основной мод
		private var defaultInfo            : TextFieldShort;
		private var isEnabled              : CheckBox;
		private var default_percentNumeric : NumericStepper;
		private var default_percent        : Array;
		private var defaultText            : NumericStepper;
		private var currentDefaultnumber   : uint;
		private var default_percentNumericInfo : TextFieldShort;
		private var defaultTextInfo            : TextFieldShort;
		
		//notifications
		private var isEnabledMy                 : CheckBox;
		private var isEnabledTeam               : CheckBox;
		private var isEnabledSquad              : CheckBox;
		private var textInfoMy                  : TextFieldShort;
		
		//levels
		private var textLevels   : TextFieldShort;
		private var level        : NumericStepper;
		private var levelStep    : NumericStepper;
		private var levelPercent : NumericStepper;
		private var textLevel        : TextFieldShort;
		private var textLevelStep    : TextFieldShort;
		private var textlevelPercent : TextFieldShort;
		private var levelPercentVec  : Array;
		private var currentLevelNumber : uint;
		private var currentLevel       : uint;
		
		//classes
		private var textClasses      : TextFieldShort;
		private var _class           : DropdownMenu;
		private var classStep        : NumericStepper;
		private var classPercent     : NumericStepper;
		private var textclass        : TextFieldShort;
		private var textclassStep    : TextFieldShort;
		private var textclassPercent : TextFieldShort;
		private var classPercentVec  : Array;
		private var currentClassNumber : uint;
		private var currentClass       : uint;
		
		//additional mods
		private var textAdditionalMods : TextFieldShort;
		private var textOneClip        : TextFieldShort;
		private var oneClipPercent     : NumericStepper;
		private var isEnabledOneClip   : CheckBox;
		private var isEnabledClip      : CheckBox;
		
		public function SaveShells() 
		{
			super();
			isModal = true;
			isCentered = true;
			canDrag = false;
		}
		
		override protected function onPopulate() : void
        {
            super.onPopulate();
            width = 460;
            height = 340;
            window.title = "Настройка мода SaveShells";
			window.useBottomBtns = true;
		
			currentLevelNumber = 1;
			currentLevel = 1;
			
			currentClassNumber = 1;
			currentClass = 1;
			
			levelPercentVec = new Array();
			for (var i : uint = 0; i < 10; ++i)
			{
				levelPercentVec.push(new Array(5))
			}
			
			classPercentVec = new Array();
			for (i = 0; i < 5; ++i)
			{
				classPercentVec.push(new Array(5))
			}
			
			currentDefaultnumber = 1;
			
			default_percentNumeric = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				maximum : 5,
				minimum : 1,
				y : 55,
				x : 60
			})) as NumericStepper;
			
			defaultText = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 120,
				maximum : 99,
				minimum : 0,
				y: 55
			})) as NumericStepper;
			
			isEnabled = addChild(App.utils.classFactory.getComponent("CheckBox", CheckBox, {
				label : "Включить мод",
				x : 5,
				y : 5
			})) as CheckBox;
			
			defaultInfo = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 450,
                x: 5,
                y: 30,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "Оповещение об окончании снарядов в процентах. Не более 5 ступеней. 0 - не используется"
			})) as TextFieldShort;
			
			default_percentNumericInfo = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 57,
                x: 5,
                y: 55,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "№ ступени"
			})) as TextFieldShort;
			
		    defaultTextInfo = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 10,
                x: 180,
                y: 55,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "%"
			})) as TextFieldShort;
		
			soundButtonApply = addChild(App.utils.classFactory.getComponent("ButtonNormal", SoundButton, {
				width: 100,
                x: 355,
                y: 320,
                label: "Принять",
				enabled : false
            })) as SoundButton;
			
			soundButtonCancel = addChild(App.utils.classFactory.getComponent("ButtonNormal", SoundButton, {
				width: 100,
                x: 250,
                y: 320,
                label: "Отмена"
            })) as SoundButton;
			
			
			soundButtonOk = addChild(App.utils.classFactory.getComponent("ButtonNormal", SoundButton, {
				width: 100,
                x: 145,
                y: 320,
                label: "ОК"
            })) as SoundButton;
			
			textInfoMy = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 178,
                x: 5,
                y: 80,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "Оповещать об окончании снарядов:"
			})) as TextFieldShort;
			
			isEnabledMy  = addChild(App.utils.classFactory.getComponent("CheckBox", CheckBox, {
				label : "Мне",
				x : 188,
				y : 80
			})) as CheckBox;
			
			isEnabledMy.addEventListener(MouseEvent.CLICK, enabledApplyButton);
			
			isEnabledSquad = addChild(App.utils.classFactory.getComponent("CheckBox", CheckBox, {
				label : "Совзводным",
				x : 240,
				y : 80
			})) as CheckBox;
			
			isEnabledSquad.addEventListener(MouseEvent.CLICK, enabledApplyButton);
			
			isEnabledTeam = addChild(App.utils.classFactory.getComponent("CheckBox", CheckBox, {
				label : "Команде",
				x : 337,
				y : 80
			})) as CheckBox;
			
			textLevels = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				label : "Настройка % в зависимости от уровня:",
				textColor : isEnabled.textColor,
				width : 200,
				buttonMode : false,
				x : 5,
				y : 105
			})) as TextFieldShort;
			
			textLevel = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				label : "Уровень",
				textColor : isEnabled.textColor,
				width : 50,
				buttonMode : false,
				x : 5,
				y : 130
			})) as TextFieldShort; 
			
			level = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 50,
				maximum : 10,
				minimum : 1,
				y: 130
			})) as NumericStepper;
			
			level.addEventListener(IndexEvent.INDEX_CHANGE, onLevelChanged)
			
			textLevelStep = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 57,
                x: 110,
                y: 130,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "№ ступени"
			})) as TextFieldShort;
			
			levelStep = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 165,
				maximum : 5,
				minimum : 1,
				y: 130
			})) as NumericStepper;
			
			levelStep.addEventListener(IndexEvent.INDEX_CHANGE, onLevelStepChanged);
			
			textlevelPercent = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 10,
                x: 285,
                y: 130,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "%"
			})) as TextFieldShort;
			
			levelPercent = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 225,
				maximum : 99,
				minimum : 0,
				y: 130
			})) as NumericStepper;
			
			//1
			
			textClasses = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				label : "Настройка % в зависимости от класса:",
				textColor : isEnabled.textColor,
				width : 200,
				buttonMode : false,
				x : 5,
				y : 155
			})) as TextFieldShort;
			
			textclass = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				label : "Класс",
				textColor : isEnabled.textColor,
				width : 50,
				buttonMode : false,
				x : 5,
				y : 180
			})) as TextFieldShort; 
			
			var data : Array = new Array();
			data.push("ЛТ");
			data.push("СТ");
			data.push("ТТ");
			data.push("ПТ");
			data.push("САУ");
			var dataProv : DataProvider = new DataProvider(data);
			
			_class = addChild(App.utils.classFactory.getComponent("DropdownMenu", DropdownMenu, {
				width: 60,
				x: 50,
				itemRenderer: "DropDownListItemRendererSound",
				dropdown: "DropdownMenu_ScrollingList",
				menuRowCount: dataProv.length,
				dataProvider: dataProv,
				selectedIndex: 0,
				y: 180
			})) as DropdownMenu;
			
			textclassStep = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 57,
                x: 110,
                y: 180,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "№ ступени"
			})) as TextFieldShort;
			
			classStep = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 165,
				maximum : 5,
				minimum : 1,
				y: 180
			})) as NumericStepper;
			
			textclassPercent = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 10,
                x: 285,
                y: 180,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "%"
			})) as TextFieldShort;
			
			classPercent = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 225,
				maximum : 99,
				minimum : 0,
				y: 180
			})) as NumericStepper;
			
			textAdditionalMods = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 120,
                x: 5,
                y: 205,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "Дополнительные моды:"
			})) as TextFieldShort;
			
			isEnabledOneClip = addChild(App.utils.classFactory.getComponent("CheckBox", CheckBox, {
				label : "Уведомление об окончании снарядов в барабане",
				width : 295,
				x : 30,
				y : 230
			})) as CheckBox;
			
			textOneClip = addChild(App.utils.classFactory.getComponent("TextFieldShort", TextFieldShort, {
				width: 220,
                x: 30,
                y: 255,
				textColor : isEnabled.textColor,
				buttonMode : false,
				label : "Количество процентов снарядов в барабане"
			})) as TextFieldShort;
			
			oneClipPercent = addChild(App.utils.classFactory.getComponent("NumericStepper", NumericStepper, {
				x: 250,
				maximum : 99,
				minimum : 1,
				y: 255
			})) as NumericStepper;
			
			isEnabledClip = addChild(App.utils.classFactory.getComponent("CheckBox", CheckBox, {
				label : "Уведомление о нехватке снарядов для следующего барабана",
				width : 365,
				x : 30,
				y : 280
			})) as CheckBox;
			
			_class.addEventListener(DropdownMenuEvent.CLOSE_DROP_DOWN, onClassChanged);
			classStep.addEventListener(MouseEvent.CLICK, onClassStepChanged);
			
			isEnabledTeam.addEventListener(MouseEvent.CLICK, enabledApplyButton);
			isEnabled.addEventListener(MouseEvent.CLICK, onIsEnabled);
			isEnabledOneClip.addEventListener(MouseEvent.CLICK, onIsEnabledOneClipClicked);
			isEnabledClip.addEventListener(MouseEvent.CLICK, enabledApplyButton);
			defaultText.addEventListener(IndexEvent.INDEX_CHANGE, enabledApplyButtonIndex);
			
			soundButtonOk.addEventListener(MouseEvent.CLICK, onSoundButtonOkClicked);
			soundButtonCancel.addEventListener(MouseEvent.CLICK, onSoundButtonCancelClicked);
			soundButtonApply.addEventListener(MouseEvent.CLICK, onSoundButtonApplyClicked);
			
			default_percentNumeric.addEventListener(IndexEvent.INDEX_CHANGE, onDefault_percentNumericChange);
			
			default_percent = new Array(6);
			
			classPercent.addEventListener(IndexEvent.INDEX_CHANGE, enabledApplyButtonIndex);
			levelPercent.addEventListener(IndexEvent.INDEX_CHANGE, enabledApplyButtonIndex)
        }
		
		private function onIsEnabledOneClipClicked(event:MouseEvent) : void
		{
			enabledApplyButton(event);
			oneClipPercent.enabled = !isEnabledOneClip.selected;
		}
		
		private function onClassChanged(event:DropdownMenuEvent) : void
		{
			classPercentVec[currentClass - 1][currentClassNumber - 1] = classPercent.value;
			currentClass = _class.selectedIndex + 1;
			if (classPercentVec[currentClass - 1][currentClassNumber - 1] == null)
			{
				classPercent.value = 0;
			}
			else
			{
				classPercent.value = classPercentVec[currentClass - 1][currentClassNumber - 1];
			}
		}
		
		private function onClassStepChanged(event: Event) : void
		{
			classPercentVec[currentClass - 1][currentClassNumber - 1] = classPercent.value;
			currentClassNumber = classStep.value;
			classPercent.value = classPercentVec[currentClass - 1][currentClassNumber - 1];
			if (classPercentVec[currentClass - 1][currentClassNumber - 1] == null)
			{
				classPercent.value = 0;
			}
			else
			{
				classPercent.value = classPercentVec[currentClass - 1][currentClassNumber - 1];
			}
		}
		
		private function onLevelChanged(event:Event) : void
		{
			levelPercentVec[currentLevel - 1][currentLevelNumber - 1] = levelPercent.value;
			currentLevel = level.value;
			if (levelPercentVec[currentLevel - 1][currentLevelNumber - 1] == null)
			{
				levelPercent.value = 0;
			}
			else
			{
				levelPercent.value = levelPercentVec[currentLevel - 1][currentLevelNumber - 1];
			}
		}
		
		private function onLevelStepChanged(event:Event) : void
		{
			levelPercentVec[currentLevel - 1][currentLevelNumber - 1] = levelPercent.value;
			currentLevelNumber = levelStep.value;
			if (levelPercentVec[currentLevel - 1][currentLevelNumber - 1] == null)
			{
				levelPercent.value = 0;
			}
			else
			{
				levelPercent.value = levelPercentVec[currentLevel - 1][currentLevelNumber - 1];
			}
		}
		
		private function onSoundButtonCancelClicked(event:MouseEvent) : void
		{
			handleWindowClose();
		}
		
		private function onSoundButtonApplyClicked(event:MouseEvent) : void
		{
			levelPercentVec[currentLevel - 1][currentLevelNumber - 1] = levelPercent.value;
			classPercentVec[currentClass - 1][currentClassNumber - 1] = classPercent.value;
			default_percent[currentDefaultnumber - 1] = defaultText.value;
			onApplyButton(isEnabled.selected, default_percent, isEnabledMy.selected, isEnabledSquad.selected, isEnabledTeam.selected, levelPercentVec, classPercentVec, isEnabledOneClip.selected, oneClipPercent.value, isEnabledClip.selected);
			soundButtonApply.enabled = false;
		}
		
		public function as_getSettings(enabled : Boolean, defaultPercents : Array, my : Boolean, squad : Boolean, team : Boolean, levelPercents : Array, classPercents : Array, oneClip : Boolean, oneClipPercent : uint, clip : Boolean) : void
		{	
			isEnabled.selected = enabled;
			default_percent = defaultPercents;
			isEnabledMy.selected = my;
			isEnabledSquad.selected = squad;
			isEnabledTeam.selected = team;
			levelPercentVec = levelPercents;
			classPercentVec = classPercents;
			
			if (classPercentVec[currentClass - 1][currentClassNumber - 1] == null)
			{
				classPercent.value = 0;
			}
			else
			{
				classPercent.value = classPercentVec[currentClass - 1][currentClassNumber - 1];
			}
			
			this.oneClipPercent.value = oneClipPercent;
			isEnabledClip.selected = clip;
			var tmpEvent : MouseEvent = new MouseEvent(MouseEvent.CLICK)
			onIsEnabledOneClipClicked(tmpEvent);
			onIsEnabled(tmpEvent);
			
			default_percentNumeric.enabled = enabled;
			defaultText.enabled = enabled;
			isEnabledMy.enabled = enabled;
			isEnabledTeam.enabled = enabled;
			isEnabledSquad.enabled = enabled;
			level.enabled = enabled;
			levelStep.enabled = enabled;
			levelPercent.enabled = enabled;
			_class.enabled = enabled;
			classStep.enabled = enabled;
			classPercent.enabled = enabled;
			isEnabledClip.enabled = enabled;
			isEnabledOneClip.enabled = enabled;
			
			isEnabledOneClip.selected = oneClip;
			
			this.oneClipPercent.enabled = isEnabledOneClip.selected && isEnabled.selected;
			
			if (default_percent[currentDefaultnumber - 1] == null)
			{
				defaultText.value = 0;
			}
			else
			{
				defaultText.value = default_percent[currentDefaultnumber - 1];
			}
			if (levelPercentVec[currentLevel - 1][currentLevelNumber - 1] == null)
			{
				levelPercent.value = 0;
			}
			else
			{
				levelPercent.value = levelPercentVec[currentLevel - 1][currentLevelNumber - 1];
			}
			if (classPercentVec[currentClass - 1][currentClassNumber - 1] == null)
			{
				classPercent.value = 0;
			}
			else
			{
				classPercent.value = classPercentVec[currentClass - 1][currentClassNumber - 1];
			}
			
			soundButtonApply.enabled = false;
		}
		
		private function onSoundButtonOkClicked(event:MouseEvent) : void
		{
			if (soundButtonApply.enabled)
			{
				onSoundButtonApplyClicked(event);
			}
			handleWindowClose();
		}
		
		private function onDefault_percentNumericChange(event:Event) : void
		{
			default_percent[currentDefaultnumber - 1] = defaultText.value;
			currentDefaultnumber = default_percentNumeric.value;
			defaultText.value = default_percent[currentDefaultnumber - 1]; 
			if (default_percent[currentDefaultnumber - 1] == null)
			{
				defaultText.value = 0;
			}
			else
			{
				defaultText.value = default_percent[currentDefaultnumber - 1];
			}
		}
		
		private function enabledApplyButton(event:MouseEvent) : void      
		{
			soundButtonApply.enabled = true;
		}
		
		private function enabledApplyButtonIndex(event:Event) : void      
		{
			soundButtonApply.enabled = true;
		}
		
		private function onIsEnabled(event:MouseEvent) : void      
		{
			var enabled : Boolean = !isEnabled.selected;
			default_percentNumeric.enabled = enabled;
			defaultText.enabled = enabled;
			isEnabledMy.enabled = enabled;
			isEnabledTeam.enabled = enabled;
			isEnabledSquad.enabled = enabled;
			level.enabled = enabled;
			levelStep.enabled = enabled;
			levelPercent.enabled = enabled;
			_class.enabled = enabled;
			classStep.enabled = enabled;
			classPercent.enabled = enabled;
			isEnabledClip.enabled = enabled;
			isEnabledOneClip.enabled = enabled;
			enabledApplyButton(event);
			oneClipPercent.enabled = isEnabledOneClip.selected && !isEnabled.selected
		}
	}	
}
