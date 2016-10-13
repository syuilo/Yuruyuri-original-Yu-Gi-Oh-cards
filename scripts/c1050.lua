--大室櫻子
--①：自分フィールド上に「古谷向日葵」が表側表示で存在する場合、このカードは手札から特殊召喚する事ができる。
--②：このカードが召喚に成功した時、デッキからレベル3以下のゆるゆりキャラ1人を選択し特殊召喚できる。
--③：このカードが相手によって破壊された時、デッキから「古谷向日葵」1人を特殊召喚できる。

function c1050.initial_effect(c)

	-- special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1050, 0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c1050.spcon)
	c:RegisterEffect(e2)

	-- summon success
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1050, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c1050.e2target)
	e2:SetOperation(c1050.e2operation)
	c:RegisterEffect(e2)

	-- special summon
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1050, 2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c1050.e3condition)
	e3:SetTarget(c1050.e3target)
	e3:SetOperation(c1050.e3operation)
	c:RegisterEffect(e3)

end

-- 向日葵フィルター
function c1050.spfilter(c)
	-- 表側表示(=IsFaceup)かつ向日葵(=1080)か
	return c:IsFaceup() and c:IsCode(1080)
end

function c1050.spcon(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1050.spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

function c1050.e2filter(c,e,sp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x186A0) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end

function c1050.e2target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1050.e2filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function c1050.e2operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1050.e2filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function c1050.e3condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and e:GetHandler():GetPreviousControler()==tp
end
function c1050.e3filter(c,e,tp)
	return c:IsCode(1080) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c1050.e3target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and c1050.e3filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c1050.e3filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c1050.e3filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c1050.e3operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
