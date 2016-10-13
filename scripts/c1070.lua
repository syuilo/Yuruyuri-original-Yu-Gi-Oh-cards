-- 大室花子
-- ①：自分フィールド上に「大室櫻子」が表側表示で存在する場合、このカードは手札から特殊召喚することができる。
-- ②：このカードが召喚に成功した時、デッキから「古谷楓」を1枚手札に加えることができる。
-- ③：このカードが相手によって破壊され墓地へ送られた時、自分のデッキから「大室櫻子」を特殊召喚することができる。

function c1070.initial_effect(c)

	-- special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1070, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1070.e1condition)
	c:RegisterEffect(e1)

	-- search
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1070, 1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c1070.e2target)
	e2:SetOperation(c1070.e2operation)
	c:RegisterEffect(e2)

	-- special summon when to grave
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1070, 2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c1070.e3condition)
	e3:SetTarget(c1070.e3target)
	e3:SetOperation(c1070.e3operation)
	c:RegisterEffect(e3)

end

-- 櫻子フィルター
function c1070.e1spfilter(c)
	-- 表側表示(=IsFaceup)かつ櫻子(=1050)か
	return c:IsFaceup() and c:IsCode(1050)
end

function c1070.e1condition(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1070.e1spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

-- 楓フィルター
function c1070.e2filter(c)
	return c:IsCode(1090) and c:IsAbleToHand()
end

function c1070.e2target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c1070.e2filter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function c1070.e2operation(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, c1070.e2filter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if g:GetCount() > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

function c1070.e3condition(e, tp, eg, ep, ev, re, r, rp)
	return rp~=tp and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end

-- (特殊召喚する)櫻子フィルター
function c1070.e3filter(c, e, tp)
	return c:IsCode(1050) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function c1070.e3target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and c1070.e3filter(chkc, e, tp) end
	if chk == 0 then return Duel.IsExistingTarget(c1070.e3filter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp, c1070.e3filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function c1070.e3operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end
